module StoryTeller
  class Railtie < ::Rails::Railtie
    class ProtectedNameError < StandardError; end

    puts "In railtie"
    config.story_teller = StoryTeller.config

    initializer "story_teller.middleware" do |app|
      app.config.middleware.insert_after Rails::Rack::Logger, app.config.middlewares.rails
    end

    initializer "story_teller.action_controller" do |app|
      if StoryTeller.config.extensions.include?("action_controller")
        require "story_teller/initializers/action_controller"
      end
    end

    initializer "story_teller.level_methods" do
      puts "Defining levels!"
      StoryTeller.config.define_levels!
    end

    initializer "story_teller.filter_parameters" do |app|
      # Include Rails's default filter parameters, otherwise
      # Use our own.
    end

    initializer "story_teller.jobs" do
      if defined?(::Sidekiq)
        require "story_teller/initializers/sidekiq"
      end
    end

    after_initialize do
      config.story_teller.freeze!
    end
  end
end
