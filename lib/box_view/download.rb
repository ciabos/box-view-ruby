module BoxView
  # Provides access to the BoxView Download API. The Download API is used for
  # downloading an original of a document, a PDF of a document, a thumbnail of a
  # document, and text extracted from a document.
  class Download
    VALID_EXTENSIONS = [:pdf, :zip, :txt]

    def self.document(id, extension: :pdf)
      raise "Invalid extension: #{extension}" unless VALID_EXTENSIONS.include?(extension)

      BoxView._request("documents/#{id}/content.#{extension.to_s}", :json_response => false)
    end

    def self.thumbnail(id, width:, height:)
      return BoxView::_error('invalid_dimensions', name, __method__, nil) unless width && height

      params = {:width => width, :height => height}
      BoxView._request("documents/#{id}/thumbnail", params, :json_response => false,
        :raise_unless_ready => true)
    end
  end
end
