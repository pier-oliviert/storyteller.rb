require "story_teller/message"

class StoryTeller::Story
  attr_reader :attributes, :message, :chapter, :timestamp

  def initialize(message: "", chapter: nil, **data)
    self.timestamp = Time.now.utc
    self.message = StoryTeller::Message.new(message)
    self.attributes = data.symbolize_keys
    self.chapter = chapter
  end

  def to_hash
    {
      timestamp: timestamp.strftime("%s%N"),
      message: message.render(attributes),
      data: {
        story: attributes,
        chapter: chapter&.attributes
      }
    }
  end

  private
  attr_writer :timestamp, :message, :attributes, :chapter
end
