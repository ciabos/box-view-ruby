module BoxView
  # Provides access to the BoxView Session API. The Session API is used to
  # to create sessions for specific documents that can be used to view a
  # document using a specific session-based URL.
  class Session
    # The Session API path relative to the base API path
    @@path = '/session/'
    
    # Set the path
    def self.path=(path)
      @@path = path
    end
    
    # Get the path
    def self.path
      @@path
    end
    
    # Create a session for a specific document by UUID that is optionally
    # editable and can use user ID and name info from your application,
    # can filter annotations, can grant admin permissions, can be
    # downloadable, can be copy-protected, and can prevent changes from being
    # persisted.
    # 
    # @param [String] uuid The uuid of the file to create a session for
    # @param [Hash<String,>] params A hash representing:
    #   [Boolean] 'is_editable' Can users create annotations and comments while
    #     viewing the document with this session key?
    #   [Hash<String, String>] 'user' A hash with keys "id" and "name"
    #     representing a user's unique ID and name in your application; "id"
    #     must be a non-negative signed 32-bit integer; this field is required
    #     if is_editable is true
    #   [String, Array<String>] 'filter' Which annotations should be included
    #     if any - this is usually a string, but could also be an array if it's
    #     a comma-separated list of user IDs as the filter
    #   [Boolean] 'is_admin' Can users modify or delete any annotations or comments
    #     belonging to other users?
    #   [Boolean] 'is_downloadable' Can users download the original document?
    #   [Boolean] 'is_copyprotected' Can text be selected in the document?
    #   [Boolean] 'is_demo' Should we prevent any changes from being persisted?
    #   [String] 'sidebar' Sets if and how the viewer sidebar is included
    # 
    # @return [String] A unique session key for the document
    # @raise [BoxViewError]
    def self.create(uuid, params = {})
      post_params = {uuid: uuid}

      if params.has_key? 'is_editable'
        post_params['editable'] = params['is_editable'] ? 'true' : 'false'
      end
      
      if (
        params.has_key? 'user' \
        and params['user'] \
        and params['user'].is_a? Hash \
        and params['user'].has_key? 'id' \
        and params['user'].has_key? 'name' \
      )
        post_params['user'] = String(params['user']['id']) + ',' + params['user']['name']
      end
      
      if params.has_key? 'filter'
        if params['filter'].is_a? Array
          params['filter'] = params['filter'].join(',')
        end
        
        post_params['filter'] = params['filter']
      end
      
      if params.has_key? 'is_admin'
        post_params['admin'] = params['is_admin'] ? 'true' : 'false'
      end
      
      if params.has_key? 'is_downloadable'
        post_params['downloadable'] = params['is_downloadable'] ? 'true' : 'false'
      end
      
      if params.has_key? 'is_copyprotected'
        post_params['copyprotected'] = params['is_copyprotected'] ? 'true' : 'false'
      end
      
      if params.has_key? 'is_demo'
        post_params['demo'] = params['is_demo'] ? 'true' : 'false'
      end

      post_params['sidebar'] = params['sidebar'] if params.has_key? 'sidebar'
      
      session = BoxView._request(self.path, 'create', nil, post_params)
      
      unless session.is_a? Hash and session.has_key? 'session'
        return BoxView._error('missing_session_key', self.name, __method__, session)
      end
      
      session['session']
    end
  end
end
