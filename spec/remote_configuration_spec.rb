require 'spec_helper'
describe Remote::Configuration, "#new" do
  it "should initialize" do
    Remote::Configuration.new.should be
  end

  # defaults
  {
    hosts:        [ "localhost" ],
    ssh_opts:     {},
    threaded:     false,
    verbose:      false,
    quiet:        false,
    threaded:     false,
    max_threads:  5,
    group:        "default"
  }.each do |meth,value|
    it "should have correct default -- #{meth}" do
      Remote::Configuration.new.send(meth).should eq value
    end
  end
  it "should have correct default -- username" do
    uname = %x{whoami}.strip
    Remote::Configuration.new.username.should eq uname
  end
  it "commands should raise error when not set" do
    expect { Remote::Configuration.new.commands }.to raise_error
  end
  it "commands should raise error when not array" do
    conf = Remote::Configuration.new
    conf.commands = { :raise => :error }
    expect { conf.commands }.to raise_error
  end
  it "hosts should raise error when not array" do
    conf = Remote::Configuration.new
    conf.hosts = { :raise => :error }
    expect { conf.hosts }.to raise_error
  end
end

describe Remote::Configuration, "attributes" do
  before(:all) do
    @config = Remote::Configuration.new
  end

  # updates 
  {
    hosts:        [ "foobar.com" ],
    username:     "foobar",
    ssh_opts:     { :password => "foobar" },
    threaded:     true,
    verbose:      true,
    quiet:        true,
    max_threads:  7,
    group:        "foobar",
  }.each do |meth,value|
    it "should set correctly -- #{meth}" do
      @config.send("#{meth}=", value)
      @config.send(meth).should eq value
    end
  end
end
