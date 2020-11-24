# frozen_string_literal: true

require_relative 'lib/strictly_fake/version'

# rubocop:disable Layout/LineLength
Gem::Specification.new do |spec|
  spec.name          = 'strictly_fake'
  spec.version       = StrictlyFake::VERSION
  spec.authors       = ['artemave']
  spec.email         = ['artemave@gmail.com']

  spec.summary       = 'Stub that automatically verifies that stubbed methods exist and the signatures match the original.'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/featurist/strictly_fake'
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
# rubocop:enable Layout/LineLength
