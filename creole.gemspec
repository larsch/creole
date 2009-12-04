# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{creole}
  s.version = '0.3.3'

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lars Christensen", "Daniel Mendler"]
  s.date = %q{2009-02-16}
  s.description = %q{Creole is a Creole-to-HTML converter for Creole, the lightwight markup language (http://wikicreole.org/).}
  s.email = ["larsch@belunktum.dk", "mail@daniel-mendler.de"]
  s.extra_rdoc_files = ["Manifest.txt", "README.txt"]
  s.files = ["Manifest.txt", "README.txt", "Rakefile", "lib/creole.rb", "test/test_creole.rb", "test/testcases.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/minad/creole}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{creole}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Creole is a Creole-to-HTML converter for Creole, the lightwight markup language (http://wikicreole.org/).}
  s.test_files = ["test/test_creole.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.8.3"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.3"])
  end
end
