module StoryTeller
  require "story_teller/configuration"
  require "story_teller/levels"
  require "story_teller/book"
  require "story_teller/backends"

  module_function

  def chapter(title: "", subtitle: "", &block)
    chapter = StoryTeller::Chapter.new(
      title: title,
      subtitle: subtitle,
      parent: book.current_chapter
    )

    book.write(chapter, &block)
  end

  def book
    StoryTeller::Book.current_book
  end

  def config
    @config ||= StoryTeller::Configuration.new
  end
end

if defined?(::Rails::Engine)
  require "story_teller/railtie"
end
