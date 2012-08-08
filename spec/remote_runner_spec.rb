require 'spec_helper'
describe Remote::Runner, "#new" do
  it "should initiize empty" do
    expect { Remote::Runner.new }.to_not raise_error
  end
  it "should initize with options which configure" do
    rr = Remote::Runner.new( hosts: [ "foo.com", "bar.com" ], commands: "hostname" )
    Remote.configuration.hosts.should eq [ "foo.com", "bar.com" ]
    Remote.configuration.commands.should eq [ "hostname" ]
  end
  after(:all) { Remote.reset }
end

describe Remote::Runner, "#configure" do
  before(:all) do
    @rr = Remote::Runner.new
  end
  it "should initize with options which configure" do
    Remote.configure do |c|
      c.hosts = [ "foo.com", "bar.com" ]
      c.commands = "hostname" 
    end
    Remote.configuration.hosts.should eq [ "foo.com", "bar.com" ]
    Remote.configuration.commands.should eq [ "hostname" ]
  end
  after(:all) { Remote.reset }
end

describe Remote::Runner, "#run" do
  before(:all) do
    Remote.configure do |c|
      c.commands = "hostname" 
      c.username = "jmervine"
    end
    @rr = Remote::Runner.new
  end
  it "should should run on a single host" do
    here = %x{ hostname }.strip
    out = capture(:stdout, :stderr) do
      @rr.run
    end
    out.split(here).count.should eq 2
  end
  it "should should run on multiple hosts" do
    Remote.configure do |c|
      c.hosts = [ "localhost" ]*2
    end
    here = %x{ hostname }.strip
    out = capture(:stdout, :stderr) do
      @rr.run
    end
    out.split(here).count.should eq 3
  end
  after(:all) { Remote.reset }
end

describe Remote::Runner, "#run threaded" do
  before(:all) do
    Remote.configure do |c|
      c.commands = "hostname" 
      c.username = "jmervine"
      c.hosts    = "localhost"
      c.threaded = true
    end
    @rr = Remote::Runner.new
  end
  it "should should run on a single host" do
    here = %x{ hostname }.strip
    out = capture(:stdout, :stderr) do
      @rr.run
    end
    out.split(here).count.should eq 2
  end
  it "should should run on multiple hosts" do
    @rr.configuration.hosts = [ "localhost" ]*6
    here = %x{ hostname }.strip
    out = capture(:stdout, :stderr) do
      @rr.run
    end
    out.split(here).count.should eq 7
    @rr.instance_variable_get(:@waited).should be_true
  end
  after(:all) { Remote.reset }
end

describe Remote::Runner, "misc" do
  describe "dry run" do
    it "should print commands on dry runs" do
      Remote.configure("./spec/dummy_config.yml") do |c|
        c.commands = "invalidcommand"
        c.dry_run
      end
      @rr = Remote::Runner.new
      out = capture(:stdout, :stderr) do
        @rr.run
      end
      out.should eq "[localhost::echo] invalidcommand\n"
    end
  end

  describe "stderr handling" do
    it "should capture and report on error" do
      Remote.configure("./spec/dummy_config.yml") do |c|
        c.dry_run = false
        c.commands = "invalidcommand"
      end
      @rr = Remote::Runner.new
      out = capture(:stdout, :stderr) do
        @rr.run
      end
      out.should match /command not found/
      out.should match /exit failed/
    end
  end

  after(:all) { Remote.reset }
end
