class StoryTeller::Chapter
  attr_reader :attributes

  def initialize(title: "", subtitle: "", parent: nil)
    @attributes = {}
    @title = title
    @subtitle = subtitle

    if parent.present?
      @attributes = @attributes.merge(parent.attributes)
    end
  end

  def write(&block)
    returned_value = nil
    returned_value = block.call(self) if block_given?
  rescue StandardError => error
    StoryTeller.error(StoryTeller::Error.new(error))
    raise error
  ensure
    returned_value
  end
end
