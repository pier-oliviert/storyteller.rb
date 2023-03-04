class StoryTeller::Exception
  attr_reader :chapter, :exception, :timestamp

  def initialize(exception:, chapter: nil)
    self.timestamp = Time.now.utc
    self.exception = exception
    self.chapter = chapter
  end

  def to_hash
    {
      timestamp: timestamp.strftime("%s%N"),
      message: exception.description,
      data: {
        story: exception.backtrace,
        chapter: chapter&.attributes
      }
    }
  end

  private
  attr_writer :chapter, :exception, :timestamp
end