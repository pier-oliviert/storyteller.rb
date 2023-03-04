class StoryTeller::Formatters::Development::Error < StoryTeller::Formatters::Base
  COLORS = {
    default: 0,
    black: 30,
    red: 31,
    green: 32,
    yellow: 33,
    blue: 34,
    magenta: 35,
    cyan: 36,
    light_gray: 37,
    light_grey: 37,
    gray: 90,
    grey: 90,
    light_red: 91,
    light_yellow: 93,
    light_blue: 95,
    light_magenta: 94,
    light_cyan: 96,
    white: 97
  }.freeze

  def config
    @backtrace_cleaner = Rails.backtrace_cleaner
    @colors = {
      message: COLORS[:red],
      trace: "1;#{COLORS[:red]}"
    }
  end


  def write(story)
    exception = story.exception
    output << color("#{exception.class} (#{exception.message})", :message) << "\n"

    trace = @backtrace_cleaner.clean(exception.backtrace, :noise).reverse
    trace[-1] = color(trace.last, :trace)

    output << "Backtrace: \t" << trace.join("\n\t\t") << "\n"

    if output.respond_to?(:flush)
      output.flush
    end
  end

  private

  def color(text, type)
    "\e[1;#{@colors[type]}m#{text}\e[0m"
  end

end