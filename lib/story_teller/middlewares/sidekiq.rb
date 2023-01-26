class StoryTeller::Middlewares::Sidekiq::Client
  include Sidekiq::ClientMiddleware

  def call(worker, job, queue, redis_pool)
    chapter = StoryTeller.book.current_chapter
    if chapter.attributes.key?(:request_id)
      msg[:request_id] = chapter.attributes[:request_id]
    end

    yield
  end
end

class StoryTeller::Middlewares::Sidekiq::Server
  include Sidekiq::ServerMiddleware

  def call(worker, job, queue)
    chapter = StoryTeller.book.current_chapter
    if job.key?(:request_id)
      chapter.attributes[:request_id] = job[:request_id]
    end

    chapter[:job] = job.class

    yield
  ensure
    StoryTeller.clear!
  end
end
