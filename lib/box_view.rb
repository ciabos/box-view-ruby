require 'json'
require 'httpclient'
require_relative 'box_view_error'
require_relative 'box_view/document'
require_relative 'box_view/download'
require_relative 'box_view/session'

module BoxView
  class << self
    attr_accessor :api_token
  end

  # Handle an error. We handle errors by throwing an exception.
  # 
  # @param [String] error An error code representing the error
  #   (use_underscore_separators)
  # @param [String] client Which API client the error is being called from
  # @param [String] method Which method the error is being called from
  # @param [Hash<String,>, String] response This is a hash of the response,
  #   usually from JSON, but can also be a string
  # 
  # @raise [BoxViewError]
  def self._error(error, client, method, response)
    message = name + ': [' + error + '] ' + client + '.' + String(method) + "\r\n\r\n"
    response = JSON.generate(response) if response.is_a? Hash
    message += response unless response.nil?
    raise BoxViewError.new(message, error)
  end

  def self._request(path, params = {}, json_response: true, method: :get, version: 1, raise_unless_ready: false)
    response =
      http_client(version).request(
        method,
        path,
        request_options(method, params)
      )

    http_code = Integer(response.code)

    if http_code == 202 && raise_unless_ready
      raise BoxViewError::NotReady.new("Resource is not yet ready: #{path}")
    end

    raise BoxViewError::RateLimitExceeded.new("Rate Limit Exceeded") if http_code == 429

    http_4xx_error_codes = {
      400 => 'bad_request',
      401 => 'unauthorized',
      404 => 'not_found',
      405 => 'method_not_allowed',
      415 => 'unsupported_media_type'
    }

    if http_4xx_error_codes.has_key? http_code
      error = 'server_error_' + http_code.to_s + '_' + http_4xx_error_codes[http_code]
      return _error(error, self.name, __method__, :url => response.header.request_uri.to_s, :params => params)
    end

    if http_code >= 500 and http_code < 600
      error = 'server_error_' + http_code.to_s + '_unknown'
      return _error(error, self.name, __method__, :url => response.header.request_uri.to_s, :params => params)
    end

    raise BoxViewError::NotReady.new("Resource is not yet ready or is empty: #{path}") unless response.body

    json_response ? decode_json(response.body) : response.body
  end


  def self.http_client(version)
    Thread.current["BOXVIEW_HTTPCLIENT_CONNECTION_v#{version}"] ||= HTTPClient.new(
      :base_url => "https://view-api.box.com/#{version}/",
      :default_header => {
        'Content-Type' => 'application/json; charset=utf-8',
        'Authorization' => "Token #{BoxView.api_token}"
      }
    ).tap { |client| client.keep_alive_timeout = 600 }
  end

  def self.request_options(method, params)
    case method
    when :get
      {
        :query => params
      }
    else
      {
        :body => params.to_json
      }
    end
  end

  def self.decode_json(result)
    return true if result == 'true'
    return false if result == 'false'

    json_decoded = JSON.parse(result)

    unless json_decoded
      return _error('server_response_not_valid_json', name, __method__, :response => result,
        :params => params)
    end

    if json_decoded.is_a? Hash and json_decoded.has_key? 'error'
      return _error(json_decoded['error'], name, __method__, :params => params)
    end

    json_decoded
  end
end
