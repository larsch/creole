# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{creole}
  s.version = '0.3.7'

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lars Christensen", "Daniel Mendler"]
  s.date = %q{2009-02-16}
  s.description = %q{Creole is a Creole-to-HTML converter for Creole, the lightwight markup language (http://wikicreole.org/).}
  s.email = ["larsch@belunktum.dk", "mail@daniel-mendler.de"]
  s.extra_rdoc_files = ["Manifest.txt", "README.creole"]
  s.files = ["Manifest.txt", "README.creole", "Rakefile", "lib/creole.rb", "test/creole_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/minad/creole}
  s.rdoc_options = ["--main", "README.creole"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{creole}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Creole is a Creole-to-HTML converter for Creole, the lightwight markup language (http://wikicreole.org/).}
  s.test_files = ["test/creole_test.rb"]
  s.add_development_dependency('bacon')
end
