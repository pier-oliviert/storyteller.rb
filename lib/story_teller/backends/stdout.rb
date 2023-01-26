class StoryTeller::Backends::Stdout
  def initialize(env = "production")
    @serializer = StructuredLog.new
  end

  def write(message, **data)
    puts @serializer.output(message, data)
  end

  class DevelopmentLog
    def output(message, **data)
      data = "#{message} #{expand(data)}"
    end

    def expand(**data)
      elements = []

      data.each do |k, v|
        elements.push("#{k.to_s}=#{v.to_s}")
      end

      elements.join(" ")
    end
  end

  class StructuredLog
    def output(message, **data)
      {
        message: message,
        data: data
      }
    end
  end
end
