class StoryTeller::Chapter
  attr_reader :attributes, :title, :subject

  def initialize(title: "", subject: "", parent: nil)
    @attributes = {}
    @title = title
    @subject = subject

    if parent.present?
      merge(parent)
    end
  end

  def attributes(with_title: true)
    if with_title
      @attributes.merge(title => subject)
    else
      @attributes
    end
  end

  def open(&block)
    returned_value = nil
    returned_value = block.call(self) if block_given?
  rescue Exception => e
    # This is to avoid reposting the same error over and over if
    # the error is triggered from a deeply nested chapter.
    if StoryTeller::Book.current_book.current_exception != e
      StoryTeller::Book.current_book.current_exception = e
      StoryTeller.error(StoryTeller::Exception.new(exception: e, chapter: self))
    end
    raise e
  ensure
    returned_value
  end

  private

  def merge(parent)
    @attributes = parent.attributes.merge(attributes)
  end

  attr_reader :title, :subtitle
end
