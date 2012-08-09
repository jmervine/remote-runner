# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'remote'
require 'remote/version'
 
Gem::Specification.new do |s|
  s.name        = "remote-runner"
  s.version     = Remote::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Joshua Mervine"]
  s.email       = ["joshua@mervine.net"]
  s.homepage    = "http://github.com/rubyops/remote_runner"
  s.summary     = "Run command remotely on multiple hosts."
  s.description = "Run command remotely on multiple hosts."
 
  s.required_rubygems_version = ">= 1.3.6"
 
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "yard"
  s.add_development_dependency "redcarpet"

  s.add_dependency "net-ssh"

  s.files        = Dir.glob("lib/**/*") + %w(README.md HISTORY.md)
  s.require_path = 'lib'
end

