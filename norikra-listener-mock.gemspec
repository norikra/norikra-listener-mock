# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "norikra-listener-mock"
  spec.version       = "0.0.3"
  spec.authors       = ["TAGOMORI Satoshi"]
  spec.email         = ["tagomoris@gmail.com"]
  spec.summary       = %q{Norikra listener mock}
  spec.description   = %q{Mock of Norikra listener to show how to make listener by yourself}
  spec.homepage      = "https://github.com/norikra/norikra-lilstener-mock"
  spec.license       = "GPLv2"
  spec.platform      = "java"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib", "jar"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_runtime_dependency "norikra"
end
