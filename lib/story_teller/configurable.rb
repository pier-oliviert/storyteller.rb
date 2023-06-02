module StoryTeller::Configurable
  attr_reader :formatters, :log_formatter, :warn_console_user

  def initialize
    @log_formatter = StoryTeller::Formatters::Development::Info.new(
      name: StoryTeller::Levels::INFO,
      output: STDOUT
    )

    @warn_console_user = false
    @formatters = [
      StoryTeller::Formatters::Development::Error.new(
        name: StoryTeller::Levels::ERROR,
        output: STDOUT
      ),
      log_formatter
    ]
  end
end
