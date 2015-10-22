require 'json'
require 'rest-client'
require_relative 'box_view_error'
require_relative 'box_view/document'
require_relative 'box_view/download'
require_relative 'box_view/session'

module BoxView
  # The developer's BoxView API token
  @@api_token = nil
  
  # The default protocol (BoxView uses HTTPS)
  @@protocol = 'https'
  
  # The default host
  @@host = 'view-api.box.com'
  
  # The default base path on the server where the API lives
  @@base_path = '/api/v2'
  
  # Set the API token
  def self.api_token=(api_token)
    @@api_token = api_token
  end
  
  # Get the API token
  def self.api_token
    @@api_token
  end
  
  # Set the protocol
  def self.protocol=(protocol)
    @@protocol = protocol
  end
  
  # Get the protocol
  def self.protocol
    @@protocol
  end
  
  # Set the host
  def self.host=(host)
    @@host = host
  end
  
  # Get the host
  def self.host
    @@host
  end
  
  # Set the base path
  def self.base_path=(base_path)
    @@base_path = base_path
  end
  
  # Get the base path
  def self.base_path
    @@base_path
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
    message = self.name + ': [' + error + '] ' + client + '.' + String(method) + "\r\n\r\n"
    response = JSON.generate(response) if response.is_a? Hash
    message += response unless response.nil?
    raise BoxViewError.new(message, error)
  end
  
  # Make an HTTP request. Some of the params are polymorphic - get_params and
  # post_params. 
  # 
  # @param [String] path The path on the server to make the request to
  #   relative to the base path
  # @param [String] method This is just an addition to the path, for example,
  #   in "/documents/upload" the method would be "upload"
  # @param [Hash<String, String>] get_params A hash of GET params to be added
  #   to the URL
  # @param [Hash<String, String>] post_params A hash of GET params to be added
  #   to the URL
  # @param [Boolean] is_json Should the file be converted from JSON? Defaults to
  #   true.
  # 
  # @return [Hash<String,>, String] The response hash is usually converted from
  #   JSON, but sometimes we just return the raw response from the server
  # @raise [BoxViewError]
  def self._request(path, method, get_params, post_params, is_json=true)
    url = @@protocol + '://' + @@host + @@base_path + path + method

    # add the API token to get_params
    get_params = {} unless get_params
    get_params['token'] = @@api_token
    
    # add the API token to post_params
    if post_params and post_params.length > 0
      # add the API token to post_params
      post_params['token'] = @@api_token
    end

    result = nil
    http_code = nil
    
    if post_params && post_params.length > 0
      response = RestClient.post(url, post_params, params: get_params){|response, request, result| result }
      result = RestClient::Request.decode(response['content-encoding'], response.body)
      http_code = Integer(response.code)
    else
      response = RestClient.get(url, params: get_params){|response, request, result| result }
      result = RestClient::Request.decode(response['content-encoding'], response.body)
      http_code = Integer(response.code)
    end
    
    if is_json
      json_decoded = false
      
      if result == 'true'
        json_decoded = true
      elsif result == 'false' or result == ''
        json_decoded = false
      else
        json_decoded = JSON.parse(result)
      end
  
      if json_decoded == false
        return self._error('server_response_not_valid_json', self.name, __method__, {
          response: result,
          get_params: get_params,
          post_params: post_params
        })
      end
      
      if json_decoded.is_a? Hash and json_decoded.has_key? 'error'
        return self._error(json_decoded['error'], self.name, __method__, {
          get_params: get_params,
          post_params: post_params
        })
      end
        
      result = json_decoded
    end

    http_4xx_error_codes = {400 => 'bad_request',
                            401 => 'unauthorized',
                            404 => 'not_found',
                            405 => 'method_not_allowed'}
    
    if http_4xx_error_codes.has_key? http_code
      error = 'server_error_' + http_code.to_s + '_' + http_4xx_error_codes[http_code]
      return self._error(error, self.name, __method__, {
        url: url,
        get_params: get_params,
        post_params: post_params
      })
    end
    
    if http_code >= 500 and http_code < 600
      error = 'server_error_' + http_code.to_s + '_unknown'
      return self._error(error, self.name, __method__, {
        url: url,
        get_params: get_params,
        post_params: post_params
      })
    end
    
    result
  end
end
