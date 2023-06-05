StoryTeller.config do |app, railtie|
  ::ActionController::Base.use(StoryTeller::Middleware)

  app.config.middleware.insert_after(
    ActionDispatch::RemoteIp,
    StoryTeller::Rack,
    app,
    app.config.debug_exception_response_format
  )

  app.config.middleware.delete Rails::Rack::Logger
  app.config.middleware.delete ::ActionDispatch::DebugExceptions

  app.config.story_teller.log_formatter = StoryTeller::Formatters::Structured.new(
    name: StoryTeller::Levels::INFO,
    output: STDOUT
  )
  app.config.story_teller.formatters = [
    app.config.story_teller.log_formatter
  ]

  Rails.logger = StoryTeller::Logger.new(formatter: app.config.story_teller.log_formatter, log_level: app.config.log_level)
end
