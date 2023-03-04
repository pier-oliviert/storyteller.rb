class StoryTeller::Book
  THREAD_KEY = "storyteller_book".freeze

  attr_reader :chapters

  class << self
    def current_book
      book = Thread.current[THREAD_KEY]
      return book unless book.nil?

      Thread.current[THREAD_KEY] = StoryTeller::Book.new
    end

    def clear!
      Thread.current[THREAD_KEY] = nil
    end
  end

  attr_accessor :current_exception

  def initialize
    @chapters = []
  end

  def current_chapter
    self.chapters.last
  end

  def open(chapter, &block)
    @chapters.push(chapter)
    chapter.open(&block)
  ensure
    @chapters.pop
  end

  def uuid
    @uuid ||= SecureRandom.uuid
  end
end
