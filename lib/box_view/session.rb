module BoxView
  # Provides access to the BoxView Session API. The Session API is used to
  # to create sessions for specific documents that can be used to view a
  # document using a specific session-based URL.
  class Session
    def self.create(id, **params)
      session = BoxView._request('sessions', params.merge(:document_id => id), :method => :post,
        :raise_unless_ready => true)
      
      session['id']
    end
  end
end
