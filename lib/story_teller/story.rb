class StoryTeller::Story
  attr_accessor :timestamp
  attr_reader :attributes, :message, :chapter

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
        message: attributes,
        chapter: chapter.attributes
      }
    }
  end
end
