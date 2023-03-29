require "story_teller/environments/development/configuration"
require "story_teller/environments/development/middleware"
require "story_teller/environments/development/notifications"

module StoryTeller::Environments::Development
  def self.included(mod)
    StoryTeller::Chapter.prepend(Module.new do
      attr_accessor :expand_attributes
      def merge(parent)
        if parent.expand_attributes || StoryTeller::Book.current_book.expand_attributes
          self.expand_attributes = true
        end

        @attributes = parent.attributes.merge(attributes)
      end

      def expand_attributes
        @expand_attributes || false
      end
    end)

    StoryTeller::Book.prepend(Module.new do
      attr_accessor :expand_attributes

      def expand_attributes
        @expand_attributes || false
      end
    end)

    mod.extend(Module.new do
      def expand_attributes!
        book = StoryTeller::Book.current_book
        chapter = book.current_chapter
        if chapter
          chapter.expand_attributes = true
        else
          book.expand_attributes = true
        end
      end
    end)
  end
end

module StoryTeller
  require "story_teller/environments/development/rack"
end
