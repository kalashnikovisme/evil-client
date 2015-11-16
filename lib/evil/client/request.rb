class Evil::Client
  # Data structure describing a request to remote server
  #
  # Knows how to prepare request from relative path and some data.
  #
  # Initialized by request type, uri and hash of data:
  #
  #     request = Request.new("get", "http://localhost/users/1/sms", text: "Hi")
  #
  #     request.uri
  #     # => "http://my_api.com/v1/users/1/sms"
  #     request.params
  #     # => {
  #     #      header: { "X-Request-Id" => "foobarbaz" },
  #     #      body: { text: "Hello", _method: "patch" }
  #     #    }
  #
  # @api public
  #
  class Request

    include Errors

    # Gets/sets a provider of the request_id
    #
    # A provider extracts id from a corresponding environment via +#call+ method
    #
    # @return [#call]
    #
    # @api private
    #
    def self.request_id_provider(provider = nil)
      @provider = provider if provider
      @provider || proc { ENV["HTTP_X_REQUEST_ID"] || SecureRandom.hex(16) }
    end

    # @!method initialize(type, uri, data)
    # Initializes request by type, uri and data
    #
    # @param [Symbol] type The type of the request
    # @param [String] uri  The full URI of the request
    # @param [Hash]   data The data to be send to the API
    #
    def initialize(type, uri, **data)
      @type = type.to_s
      @uri = uri || fail(PathError, @path)
      @data = data
    end

    # @!attribute [r] type
    #
    # @return [String] Type of current request
    #
    attr_reader :type

    # @!attribute [r] uri
    #
    # @return [String] The full URI of the request
    #
    attr_reader :uri

    # Request parameters
    #
    # @return [Hash]
    #
    def params
      @params ||= begin
        key = (type == "get") ? :query : :body
        { key => @data.merge(send_method) }.merge(header: headers)
      end
    end

    # Returns a standard array representation of the request
    #
    # @see [Evil::Client::Adapter#call]
    #
    # @return [Array]
    # 
    def to_a
      [request_type, uri, params]
    end

    private

    def headers
      {
        "X-Request-Id" => request_id,
        "Content-Type" => "application/json; charset=utf-8",
        "Accept"       => "application/json"
      }
    end
    
    def request_id
      @request_id ||= self.class.request_id_provider.call
    end

    def request_type
      @request_type ||= (type == "get") ? "get" : "post"
    end

    def send_method
      @send_method ||= %w(get post).include?(type) ? {} : { _method: type }
    end
  end
end
