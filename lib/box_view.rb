require 'json'
require 'rest-client'
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
    url = "https://view-api.box.com/#{version}#{path}"

    headers = {
      :content_type => 'application/json',
      :authorization => "Token #{BoxView.api_token}"
    }

    payload = method == :get ? nil : params.to_json
    headers.merge!(:params => params) if method == :get

    response =
      RestClient::Request.execute(
        :method => method,
        :url => url,
        :payload => payload,
        :headers => headers) do |response|
          response
        end

    result = RestClient::Request.decode(response['content-encoding'], response.body)
    result = decode_json(result) if json_response

    http_code = Integer(response.code)

    if http_code == 202 && raise_unless_ready
      raise BoxViewError::NotReady.new("Resource is not yet ready: #{path}")
    end

    http_4xx_error_codes = {
      400 => 'bad_request',
      401 => 'unauthorized',
      404 => 'not_found',
      405 => 'method_not_allowed',
      429 => 'rate_limit_exceeded'
    }
    
    if http_4xx_error_codes.has_key? http_code
      error = 'server_error_' + http_code.to_s + '_' + http_4xx_error_codes[http_code]
      return _error(error, self.name, __method__, :url => url, :params => params)
    end
    
    if http_code >= 500 and http_code < 600
      error = 'server_error_' + http_code.to_s + '_unknown'
      return _error(error, self.name, __method__, :url => url, :params => params)
    end
    
    result
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
