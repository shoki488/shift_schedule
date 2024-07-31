# -*- encoding: utf-8 -*-
# stub: webdriver 0.19.0 ruby lib

Gem::Specification.new do |s|
  s.name = "webdriver".freeze
  s.version = "0.19.0".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Matti Paksula".freeze]
  s.bindir = "exe".freeze
  s.date = "2021-09-01"
  s.description = "".freeze
  s.email = ["matti.paksula@iki.fi".freeze]
  s.homepage = "https://www.github.com/matti/webdriver".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.2.22".freeze
  s.summary = "webdriver".freeze

  s.installed_by_version = "3.5.14".freeze if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.2".freeze])
  s.add_development_dependency(%q<rake>.freeze, ["~> 10.0".freeze])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0".freeze])
  s.add_development_dependency(%q<guard>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<guard-rspec>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry-rescue>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<pry-stack_explorer>.freeze, [">= 0".freeze])
end
