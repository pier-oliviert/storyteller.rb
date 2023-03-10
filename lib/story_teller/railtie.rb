require "action_view/log_subscriber"
require "action_controller/log_subscriber"
require "action_mailer/log_subscriber"
require "active_job/log_subscriber"
require "active_storage/log_subscriber"
require "active_record/log_subscriber"
require "tempfile"

module StoryTeller
  class Railtie < ::Rails::Railtie
    class ProtectedNameError < StandardError; end

    case
    when Rails.env.development?
      StoryTeller.include(StoryTeller::Environments::Development)
    end

    config.story_teller = StoryTeller.config

    # Detaching the default ones from Rails
    initializer "story_teller.log_subscribers" do |app|
      ::ActionController::LogSubscriber.detach_from :action_controller
      ::ActionView::LogSubscriber.detach_from :action_view
      ::ActionMailer::LogSubscriber.detach_from :action_mailer

      ::ActiveJob::LogSubscriber.detach_from :active_job
      ::ActiveStorage::LogSubscriber.detach_from :active_storage
      ::ActiveRecord::LogSubscriber.detach_from :active_record
    end

    initializer "story_teller.logger" do |app|
      Rails.logger = StoryTeller::Logger.new(formatter: app.config.story_teller.log_formatter, log_level: app.config.log_level)
    end

    initializer "story_teller.middlewares" do |app|
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

    initializer "story_teller.finalize" do |app|
      StoryTeller.initialize!(StoryTeller.config)
    end

    console do
      file = Tempfile.new

      puts "\u{1F58B}  StoryTeller redirected logs while using the console: #{file.path}"

      config.story_teller.formatters.each do |formatter|
        formatter.replace_output!(file)
      end

      Rails::Console.prepend(StoryTeller::Console)
    end
  end
end
