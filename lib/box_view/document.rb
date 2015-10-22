module BoxView
  # Provides access to the BoxView Document API. The Document API is used for
  # uploading, checking status, and deleting documents.
  class Document
    # The Document API path relative to the base API path
    @@path = '/document/'
    
    # Set the path
    def self.path=(path)
      @@path = path
    end
    
    # Get the path
    def self.path
      @@path
    end
    
    # Delete a file on BoxView by UUID.
    # 
    # @param [String] uuid The uuid of the file to delete
    # 
    # @return [Boolean] Was the file deleted?
    # @raise [BoxViewError]
    def self.delete(uuid)
      post_params = {uuid: uuid}
      BoxView._request(self.path, 'delete', nil, post_params)
    end
    
    # Check the status of a file on BoxView by UUID. This method is
    # polymorphic and can take an array of UUIDs and return an array of status
    # hashes about those UUIDs, or can also take a one UUID string and return
    # one status hash for that UUID.
    # 
    # @param [Array<String>, String] uuids An array of the uuids of the file to
    #   check the status of - this can also be a single uuid string
    # 
    # @return [Array<Hash<String,>>, Hash<String,>] An array of hashes (or just
    #   an hash if you passed in a string) of the uuid, status, and viewable
    #   bool, or an array of the uuid and an error
    # @raise [BoxViewError]
    def self.status(uuids)
      is_single_uuid = !(uuids.is_a? Array)
      uuids = [uuids] if is_single_uuid
      get_params = {uuids: uuids.join(',')}
      response = BoxView._request(self.path, 'status', get_params, nil)
      is_single_uuid ? response[0] : response
    end

    def self.upload(url)
      return BoxView::_error('files_not_supported', self.name, __method__, nil) if file?(url)
      return BoxView::_error('invalid_url', self.name, __method__, nil) unless url.is_a?(String)

      params = {
        :url => url
      }

      response = BoxView._request('/documents', params, :method => :post)

      response['id'] || BoxView::_error('missing_id', self.name, __method__, response)
    end

    def self.file?(arg)
      arg.respond_to?(:read) && arg.respond_to?(:path)
    end
  end
end
