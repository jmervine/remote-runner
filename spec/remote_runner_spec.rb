require 'spec_helper'
describe Remote::Runner, "#new" do
  it "should initiize empty" do
    expect { Remote::Runner.new }.to_not raise_error
  end
  it "should initize with options which configure" do
    rr = Remote::Runner.new( hosts: [ "foo.com", "bar.com" ], commands: "hostname", group: "foobar" )
    Remote.configuration.hosts.should eq [ "foo.com", "bar.com" ]
    Remote.configuration.commands.should eq [ "hostname" ]
    Remote.configuration.group.should eq "foobar"
  end
  it "should initize with options which configure" do
    rr = Remote::Runner.new( hosts: [ "foo.com", "bar.com" ], commands: "hostname", group: "foobar" )
    Remote.configuration.hosts.should eq [ "foo.com", "bar.com" ]
    Remote.configuration.commands.should eq [ "hostname" ]
    Remote.configuration.group.should eq "foobar"
  end
  after(:each) do 
    Remote.reset 
  end
end

describe Remote::Runner, "#configure" do
  before(:all) do
    Remote.reset
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
      c.ssh_opts = { :keys => [ "~/.ssh/id_rsa" ] }
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
      out.should eq "[ dry::localhost ] invalidcommand\n"
    end
  end

  describe "verbose" do
    before(:all) do
      Remote.reset
    end
    it "should include commands when verbose" do
      Remote.configure do |c|
        c.commands = [ "hostname" ]
        c.verbose = true
      end
      @rr = Remote::Runner.new
      out = capture(:stdout, :stderr) do
        @rr.run
      end
      out.should match /\[ cmd::localhost \] hostname/
    end
    it "should not include commands when not verbose" do
      Remote.configure do |c|
        c.commands = [ "hostname" ]
        c.verbose = false
      end
      @rr = Remote::Runner.new
      out = capture(:stdout, :stderr) do
        @rr.run
      end
      out.should_not match /\[ cmd::localhost \] hostname/
    end
  end

  describe "quiet" do
    before(:all) do
      Remote.reset
    end
    it "should not include stream and host prefix when quiet" do
      Remote.configure do |c|
        c.commands = [ "hostname" ]
        c.quiet = true
      end
      @rr = Remote::Runner.new
      out = capture(:stdout, :stderr) do
        @rr.run
      end
      out.should_not match /\[ std::/
    end
    it "should include stream and host prefix when not quiet" do
      Remote.configure do |c|
        c.commands = [ "hostname" ]
        c.quiet = false
      end
      @rr = Remote::Runner.new
      out = capture(:stdout, :stderr) do
        @rr.run
      end
      out.should match /\[ std::/
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
    end
    it "should report when host is bad" do
      Remote.reset
      Remote.configure do |c|
        c.commands = "hostname"
        c.hosts    = "badhost"
      end
      rr = Remote::Runner.new
      out = capture(:stdout, :stderr) do
        rr.run
      end
      out.should match /host not found/
    end
  end

  describe "environment RR_FILE" do
    it "should read RR_FILE if set" do
      ENV['RR_FILE'] = "./spec/rr_file.yml"
      rr_file = Remote::Runner.new
      Remote.configuration.hosts.should eq [ "rr_file.localhost" ]
    end
  end

  after(:each) { Remote.reset }
end
