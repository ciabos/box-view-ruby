module BoxView
  # Provides access to the BoxView Document API. The Document API is used for
  # uploading, checking status, and deleting documents.
  class Document
    def self.delete(id)
      BoxView._request("documents/#{id}", :method => :delete, :json_response => false)
      true
    end

    def self.status(id)
      BoxView._request("documents/#{id}")
    end

    def self.upload(document_url, thumbnails: nil)
      return BoxView::_error('files_not_supported', self.name, __method__, nil) if file?(document_url)
      return BoxView::_error('invalid_url', self.name, __method__, nil) unless document_url.is_a?(String)

      params = {
        :url => document_url
      }

      params[:thumbnails] = thumbnails if thumbnails

      response = BoxView._request('documents', params, :method => :post)

      response['id'] || BoxView::_error('missing_id', self.name, __method__, response)
    end

    def self.file?(arg)
      arg.respond_to?(:read) && arg.respond_to?(:path)
    end
  end
end
