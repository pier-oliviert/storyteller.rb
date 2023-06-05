class StoryTeller::Configuration
  attr_accessor :formatters, :log_formatter, :warn_console_user, :procs

  def initialize
    @procs = []
  end

  def finalize!(app, railtie)
    @procs.each do |p|
      p.call(app, railtie)
    end

    freeze
  end
end
