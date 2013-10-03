Gem::Specification.new do |spec|
  spec.name        = 'rack-piwik'
  spec.version     = '0.0.1'
  spec.authors     = ['Jason L Perry', 'Daniel Stutzman']
  spec.date        = '2013-10-02'
  spec.summary     = 'Piwik for Rack applications'
  spec.description = 'Embeds Piwik Analytics tracking code in the bottom of HTML documents'
  spec.email       = 'dtstutz@gmail.com'
  spec.homepage    = 'https://github.com/danielstutzman/rack-piwik'

  spec.extra_rdoc_files = [
     "LICENSE",
     "README.rdoc"
  ]
  spec.files = [
     "README.rdoc",
     "lib/rack-piwik.rb",
     "lib/rack/piwik.rb"
  ]
  spec.require_paths = %w[lib]
  spec.test_files    = %w[test/rack/piwik_test.rb]

  spec.add_dependency 'rack'
end
