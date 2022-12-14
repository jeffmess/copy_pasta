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

  spec.bindir        = 'bin'
  spec.executables   = [] # spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activerecord', '>= 4.2'
  spec.add_runtime_dependency 'dry-inflector', '0.1'

  spec.add_development_dependency 'debug', '>= 1.0.0'
end
