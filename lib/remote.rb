$:.unshift File.dirname(__FILE__)
require 'open3'
require 'net/ssh'
require 'yaml'
require 'remote/runner'
require 'remote/configuration'

# run commands on a remote server
module Remote 

  class << self
    attr_accessor :configuration, :runner
  end

  def self.reset
    self.configuration = Configuration.new
  end

  def self.configure file=nil, &block
    self.configuration ||= Configuration.new
    if file
      @file ||= YAML.load_file(file)[configuration.group]
      @file.each do |key,val|
        self.configuration.instance_variable_set("@#{key}".to_sym, val)
      end
    end
    yield(configuration) if block 
  end

end

