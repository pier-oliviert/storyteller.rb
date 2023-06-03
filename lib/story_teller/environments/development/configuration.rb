class StoryTeller::Configuration
  include StoryTeller::Configurable

  StoryTeller::Railtie.initializer "story_teller.logger" do |app|
    Rails.logger = StoryTeller::Logger.new(formatter: app.config.story_teller.log_formatter, log_level: app.config.log_level)
  end

  StoryTeller::Railtie.initializer "story_teller.middlewares" do |app|
    ::ActionController::Base.use(StoryTeller::Middleware)

    app.config.middleware.insert_before(
      ActionDispatch::ActionableExceptions,
      StoryTeller::Rack, 
      app,
      app.config.debug_exception_response_format
    )

    app.config.middleware.delete Rails::Rack::Logger
    app.config.middleware.delete ::ActionDispatch::DebugExceptions
  end
end
