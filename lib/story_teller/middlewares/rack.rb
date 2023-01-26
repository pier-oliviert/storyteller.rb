class StoryTeller::Middlewares::Rack
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  ensure
    StoryTeller.clear!
  end
end
