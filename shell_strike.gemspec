
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "shell_strike/version"

Gem::Specification.new do |spec|
  spec.name          = "shell_strike"
  spec.version       = ShellStrike::VERSION
  spec.authors       = ["Andrew Walter"]
  spec.email         = ["andrew@xtrasimplicity.com"]

  spec.summary       = "A simple ruby gem to automatically identify valid SSH credentials for a server using custom username and password dictionaries."
  spec.homepage      = "https://github.com/xtrasimplicity/shell-strike"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "net-ssh"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "yard"
end
