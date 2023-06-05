StoryTeller.config do |app, railtie|
  ::ActionController::Base.use(StoryTeller::Middleware)

  app.config.middleware.insert_before(
    ActionDispatch::ActionableExceptions,
    StoryTeller::Rack, 
    app,
    app.config.debug_exception_response_format
  )

  app.config.middleware.delete Rails::Rack::Logger
  app.config.middleware.delete ::ActionDispatch::DebugExceptions

  app.config.story_teller.log_formatter = StoryTeller::Formatters::Development::Info.new(
    name: StoryTeller::Levels::INFO,
    output: STDOUT
  )

  app.config.story_teller.warn_console_user = false
  app.config.story_teller.formatters = [
    StoryTeller::Formatters::Development::Error.new(
      name: StoryTeller::Levels::ERROR,
      output: STDOUT
    ),
    app.config.story_teller.log_formatter
  ]

  Rails.logger = StoryTeller::Logger.new(formatter: app.config.story_teller.log_formatter, log_level: app.config.log_level)

end
