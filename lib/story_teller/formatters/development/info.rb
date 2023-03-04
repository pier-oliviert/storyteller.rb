class StoryTeller::Formatters::Development::Info < StoryTeller::Formatters::Base
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
    @colors = {
      key: COLORS[:blue],
      value: COLORS[:cyan],
      chapter: COLORS[:green],
    }
  end

  def write(story)
    data = story.to_hash
    attributes = expand(**data[:data])

    chapter = if data[:data][:chapter].present?
      data[:data][:chapter].map do |k, v|
        "#{k.to_s}=#{v.to_s}"
      end
    else
      []
    end

    output << "[" << color(chapter.join(" "), :chapter) << "] " if chapter.any?

    # Might want to allow this to be configurable by the user which could then
    # use the color(value, style) method
    if story.attributes[:level] == :error
      output << "\e[1;#{COLORS[:red]}m" << data[:message] << "\e[0;#{COLORS[:default]}m"
    else
      output << data[:message]
    end

    if attributes.size > 0
      if story.chapter&.expand_attributes || StoryTeller::Book.current_book.expand_attributes
        output << "\n\t" << attributes.join("\n\t")
      else
        output << color(" [#{attributes.size} Attribute#{attributes.size > 1 ? "s" : ""}] ", :key)
      end
    end

    output << "\n"

    if output.respond_to?(:flush)
      output.flush
    end
  end

  private

  def color(text, type)
    "\e[#{@colors[type]}m#{text}\e[0m"
  end

  def expand(**data)
    elements = []

    if data[:story].present? && data[:story].any?
      data[:story].each do |k, v|
        elements.push("#{color(k.to_s, :key)}: #{color(v.to_s, :value)}")
      end
    end

    elements
  end
end