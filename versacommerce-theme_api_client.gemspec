require_relative 'lib/versacommerce/theme_api_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'versacommerce-theme_api_client'
  spec.version       = Versacommerce::ThemeAPIClient::VERSION
  spec.authors       = ['Tobias Bühlmann']
  spec.email         = ['buehlmann@versacommerce.de']

  spec.summary       = 'API Client for the VersaCommercer Theme API.'
  spec.description   = 'This Gem acts as an API Client for the VersaCommerce Theme API.'
  spec.homepage      = 'https://github.com/versacommerce/versacommerce-theme_api_client'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(/\Aexe/) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency 'http', '0.8.3'
  spec.add_runtime_dependency 'activesupport', '~> 4.2'
  spec.add_runtime_dependency 'activemodel', '~> 4.2'

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'pry', '0.10.1'
  spec.add_development_dependency 'pry-stack_explorer', '0.4.9.2'
end
