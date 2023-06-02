require_relative "lib/story_teller/version"

Gem::Specification.new do |s|
  s.name        = "storyteller"
  s.version     = StoryTeller::Version.to_s
  s.licenses    = ["Apache-2.0"]
  s.summary     = "Observe and understand how your application is used."
  s.description = %s{
    StoryTeller is an observation framework that allows teams to
    create meaningful stories to help them understand what's going on in
    your production environment.
  }
  s.authors     = ["Pier-Olivier Thibault"]
  s.email       = "storyteller@pier-olivier.dev"
  s.homepage    = "https://github.com/pier-oliviert/storyteller.rb"
  s.metadata    = { "source_code_uri" => "https://github.com/pier-oliviert/storyteller.rb" }

  s.files = %w[storyteller.gemspec README.md LICENSE] + `git ls-files | grep -E '^(bin|lib|web)'`.split("\n")
end
