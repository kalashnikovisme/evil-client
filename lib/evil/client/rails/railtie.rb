module Evil::Client::Rails
  # Takes request_id provider and logger from Rails app
  #
  # @api private
  #
  class Railtie < Rails::Railtie
    # Uses a railtie as a request ID provider
    initializer "evil.client.request_id" do |app|
      app.middleware.use RequestID
      Evil::Client::Request.request_id_provider RequestID
    end

    # Sets logger for Rails dev/test environment
    if %w(development test).include? Rails.env
      initializer "evil.client.logger" do
        logger = Logger.new("log/evil_client.log", "daily")
        Evil::Client::Adapter.logger = logger
      end
    end
  end
end
