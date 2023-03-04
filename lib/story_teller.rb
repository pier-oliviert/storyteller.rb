module StoryTeller
  require "story_teller/configurable"
  require "story_teller/levels"
  require "story_teller/logger"
  require "story_teller/book"
  require "story_teller/exception"
  require "story_teller/chapter"
  require "story_teller/story"
  require "story_teller/formatters"
  require "story_teller/environments"
  require "story_teller/console"

  class AlreadyInitializedError < StandardError; end
  class FormatterNotAllowedWithName < StandardError; end

  module_function

  def chapter(title: "", subject: "", **options, &block)
    chapter = StoryTeller::Chapter.new(
      title: title,
      subject: subject,
      parent: book.current_chapter
    )

    book.open(chapter, **options, &block)
  end

  def book
    StoryTeller::Book.current_book
  end

  def config(&block)
    @config ||= StoryTeller::Configuration.new

    block.call(@config) if block_given?

    @config
  end

  def initialize!(config)
    raise AlreadyInitializedError if frozen?

    mod = Module.new do
      config.formatters.each do |formatter|
        func_name = formatter.name.to_sym

        if method_defined?(func_name)
          raise FormatterNotAllowedWithName, "#{func_name} is already defined as a method on StoryTeller. Please choose another name for your formatter"
        end

        define_method(func_name, ->(message, **data) {
          chapter = StoryTeller.book.current_chapter
          story = case message
          when StoryTeller::Story
            message
          when StoryTeller::Exception
            StoryTeller::Book.current_book.current_exception = message.exception
            message
          else
            StoryTeller::Story.new(message: message, chapter: chapter, **data)
          end

          formatter.write(story)
          nil
        })
      end
    end

    self.extend mod
    freeze
  end
end

if defined?(::Rails::Engine)
  require "story_teller/railtie"
end