require 'spec_helper'
describe RemoteRunner, "#new" do
  it "should initiize empty" do
    expect { RemoteRunner.new }.to_not raise_error
  end
  it "should initize with options which configure" do
    rr = RemoteRunner.new( hosts: [ "foo.com", "bar.com" ], command: "hostname" )
    rr.instance_variable_get(:@configuration).hosts.should eq [ "foo.com", "bar.com" ]
    rr.instance_variable_get(:@configuration).command.should eq "hostname"
  end
end

describe RemoteRunner, "#configure" do
  before(:all) do
    @rr = RemoteRunner.new
  end
  it "should initize with options which configure" do
    @rr.configure do |c|
      c.hosts = [ "foo.com", "bar.com" ]
      c.command = "hostname" 
    end
    @rr.instance_variable_get(:@configuration).hosts.should eq [ "foo.com", "bar.com" ]
    @rr.instance_variable_get(:@configuration).command.should eq "hostname"
  end
end

describe RemoteRunner, "#run" do
  before(:all) do
    @rr = RemoteRunner.new
    @rr.configure do |c|
      c.command = "hostname" 
    end
  end
  it "should should run on a single host" do
    here = %x{ hostname }.strip
    out = capture(:stdout, :stderr) do
      @rr.run
    end
    out.split(here).count.should eq 2
  end
  it "should should run on multiple hosts" do
    @rr.configure do |c|
      c.hosts = [ "localhost" ]*2
    end
    here = %x{ hostname }.strip
    out = capture(:stdout, :stderr) do
      @rr.run
    end
    out.split(here).count.should eq 3
  end
end

describe RemoteRunner, "#threaded" do
  before(:all) do
    @rr = RemoteRunner.new
  end
  it 'should be five by default' do
    @rr.threaded.should be_false
  end
  it 'should be updatable' do
    @rr.threaded = true
    @rr.threaded.should be_true
  end
end

describe RemoteRunner, "#run threaded" do
  before(:all) do
    @rr = RemoteRunner.new
    @rr.configure do |c|
      c.command = "hostname" 
    end
    @rr.threaded = true
  end
  it "should should run on a single host" do
    here = %x{ hostname }.strip
    out = capture(:stdout, :stderr) do
      @rr.run
    end
    out.split(here).count.should eq 2
  end
  it "should should run on multiple hosts" do
    @rr.configure do |c|
      c.hosts = [ "localhost" ]*6
    end
    here = %x{ hostname }.strip
    out = capture(:stdout, :stderr) do
      @rr.run
    end
    out.split(here).count.should eq 7
    @rr.instance_variable_get(:@waited).should be_true
  end
end

describe RemoteRunner, "misc" do
  describe :max_threads do
    before(:all) do
      @rr = RemoteRunner.new
    end
    it 'should be five by default' do
      @rr.max_threads.should eq 5
    end
    it 'should be updatable' do
      @rr.max_threads = 10
      @rr.max_threads.should eq 10
    end
  end

  describe :load_config do
    before(:all) do
      @rr = RemoteRunner.new
      @conf = YAML.load_file("./spec/dummy_config.yml")["default"]
    end
    it 'should load yaml configuration' do
      expect { @rr.load_config("./spec/dummy_config.yml") }.to_not raise_error
    end
    it 'should be set correctly -- max_threads' do
      @rr.max_threads.should eq 10
    end
    %w( ssh ssh_opts hosts command env ).each do |cmd|
      it "should be set correctly -- #{cmd}" do
        @rr.instance_variable_get(:@configuration).send(cmd.to_sym).should eq @conf[cmd]
      end
    end
    it 'should be set correctly -- username' do
      @rr.instance_variable_get(:@configuration).username.should eq "#{@conf["username"]}@"
    end
    it 'should be true          -- dry_run?' do
      @rr.instance_variable_get(:@configuration).dry_run?.should be_true
    end
  end

  describe "dry run" do
    it "should print commands on dry runs" do
      @rr = RemoteRunner.new
      @rr.load_config("./spec/dummy_config.yml")
      @rr.configure do |c|
        c.command = "invalidcommand"
      end
      out = capture(:stdout, :stderr) do
        @rr.run
      end
      out.should eq "[localhost::echo] invalidcommand\n"
    end
  end

  describe "stderr handling" do
    it "should capture and report on error" do
      @rr = RemoteRunner.new
      @rr.load_config("./spec/dummy_config.yml")
      @rr.configure do |c|
        c.command = "invalidcommand"
        c.dry_run = false
      end
      out = capture(:stdout, :stderr) do
        @rr.run
      end
      out.should match /command not found/
      out.should match /exit (\d+)$/
    end
  end

end
