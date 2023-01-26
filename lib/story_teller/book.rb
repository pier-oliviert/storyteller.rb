class StoryTeller::Book
  THREAD_KEY = "storyteller_book".freeze

  class << self
    def current_book
      book = Thread.current[THREAD_KEY]
      return book if book.present?

      Thread.current[THREAD_KEY] = StoryTeller::Book.new
    end
  end

  def initialize
    @chapters = []
  end

  def current_chapter
    current_book.chapters.last
  end

  def write(chapter, &block)
    @chapters.push(chapter)
    chapter.write(&block)
  ensure
    @chapters.pop
  end

  def uuid
    @uuid ||= SecureRandom.uuid
  end
end
