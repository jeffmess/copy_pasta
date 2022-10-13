require_relative 'lib/copy_pasta/version'

Gem::Specification.new do |spec|
  spec.name          = 'copy_pasta'
  spec.version       = CopyPasta::VERSION
  spec.authors       = ['Jeffrey van Aswegen']
  spec.email         = ['jeffmess@gmail.com']

  spec.summary       = %q{Copy active_record objects and associations blazingly fast(for ruby).}
  spec.homepage      = 'http://google.co.za' #'https://github.com/jeffmess/copy_pasta'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0') # pattern matching is used in this gem.

  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata['source_code_uri'] = %q{TODO: Put your gem's public repo URL here.}
  # spec.metadata['changelog_uri'] = %q{TODO: Put your gem's CHANGELOG.md URL here.}

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
  #   `git ls-files -z`.split('\x0').reject { |f| f.match(%r{^(test|spec|features)/}) }
  # end
  spec.bindir        = 'bin'
  spec.executables   = [] # spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '>= 4.2'
end
