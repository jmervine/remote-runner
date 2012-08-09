$:.unshift File.dirname(__FILE__)
require 'open3'
require 'net/ssh'
require 'yaml'
require 'remote/runner'
require 'remote/configuration'

# run commands on a remote server
module Remote 

  class << self
    attr_writer :configuration
    def configuration
      @configuration ||= Configuration.new
    end
  end

  def self.reset
    self.configuration = Configuration.new
  end

  def self.configure file=nil, &block
    self.configuration ||= Configuration.new
    if !file.nil?
      @file ||= YAML.load_file(file)
      @file[self.configuration.group].each do |key,val|
        self.configuration.instance_variable_set("@#{key}".to_sym, val)
      end
    end
    yield(configuration) if block 
  end

end

