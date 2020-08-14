require_relative 'lib/metastasis/version'

Gem::Specification.new do |spec|
  spec.name          = 'metastasis'
  spec.version       = Metastasis::VERSION
  spec.authors       = ['Nobuo Takizawa']
  spec.email         = ['takizawa@twogate.com']

  spec.summary       = 'Copying queries and dashboard to metabase'
  spec.description   = 'Meastasis is deploy tool for metabase queries and dashboards'
  spec.homepage      = 'https://rubygems.org/gems/metastasis'
  spec.license       = 'MIT'

  spec.executables   = ['metastasis']
  spec.bindir        = 'bin'
  spec.files         = `git ls-files -- lib/*`.split("\n")
  spec.files        += %w[README.md LICENSE]
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.add_dependency 'activerecord',  '>= 5.2.2.1'
  spec.add_dependency 'activesupport', '>= 5.2.2.1'
  spec.add_dependency 'pg',            '>= 1.1.4'
end
