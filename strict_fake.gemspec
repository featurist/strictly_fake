# frozen_string_literal: true

require_relative 'lib/strict_fake/version'

Gem::Specification.new do |spec|
  spec.name          = 'strict_fake'
  spec.version       = StrictFake::VERSION
  spec.authors       = ['artemave']
  spec.email         = ['artemave@gmail.com']

  spec.summary       = 'Stub that automatically verifies that stubbed methods exist and the signatures match.'
  spec.description   = "This is similar to Rspec's Veryfing Double, but standalone. So can be used in Minitest."
  spec.homepage      = 'https://github.com/featurist/veri_fake'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
