require 'open3'
require 'yaml'

# run commands on a remote server
class RemoteRunner 

  # gem version
  VERSION = "0.0.2"

  # @return [Fixnum] max threads to be run when running threaded
  attr_accessor :max_threads

  # @return [Boolean] threaded?
  attr_accessor :threaded

  # @return [Boolean] file configuration group
  # * defaults to "default"
  attr_accessor :group

  # @return [Boolean] did it wait when running threaded
  # * this is mostly for testing
  attr_reader :waited # mainly for specs

  # @param opt [Hash] see {#configure}
  #
  # Additional opt [Hash] params not in {Configuration}
  # * max_threads [Fixnum] see {#max_threads}
  # * threaded [Boolean] see {#threaded}
  # 
  def initialize opt={}
    @waited         = false
    @max_threads    = 5
    @threaded       = false
    @group          = "default"
    @configuration  ||= Configuration.new
    opt.each do |key,val|
      manual_config key, val
    end
  end

  # block configure
  # * see {Configuration}
  def configure 
    yield(@configuration)
  end

  # load configs from a [YAML] file
  # @param file [String] file path
  def load_config file
    YAML.load_file(file)[self.group].each do |key,val|
      manual_config key, val
    end
  end

  # run command
  def run 
    @configuration.hosts.each do |host|
      if @configuration.dry_run?
        dry_run host
      else
        if threaded
          thread_host host, cmd(host)
        else
          run_host host, cmd(host)
        end
      end
    end
    if threaded && !@configuration.dry_run?
      Thread.list.each do |t|
        t.join unless Thread.current == t
      end
    end
  end

  protected

  # @return [String] command to be run
  # @param host [String]
  def cmd host
    "#{@configuration.env} #{@configuration.ssh} #{@configuration.ssh_opts} #{@configuration.username}#{host} -- #{@configuration.command}" 
  end

  # run a command on a remote host
  # @param host [String]
  # @param cmd [String]
  def run_host host, cmd
    status = nil
    #out, err = ''
    Open3::popen3(cmd) do |stdin, stdout, stderr, wait_thr|
      pid = wait_thr.pid
      while wait_thr.alive? do
        stdout.read.split("\n").each do |line|
          $stdout << "[#{host}::stdout] #{line.chomp}\n"
          $stdout.flush
        end
        stderr.read.split("\n").each do |line|
          $stderr << "[#{host}::stderr] #{line.chomp}\n"
          $stderr.flush
        end
        sleep 1
      end
      status = wait_thr.value 
    end
    if status == 0
      $stdout << "[#{host}::stdout] exit\n"
      return true
    else
      $stderr << "[#{host}::stderr] exit #{status}\n"
      return status 
    end
  end

  # call {#run_host} using [Thread]
  # @param host [String]
  # @param cmd [String]
  def thread_host host, cmd
    while Thread.list.count >= @max_threads do
      @waited = true # for specs
      sleep 0.1
    end
    Thread.new do
      run_host host, cmd
    end
  end

  # echo host and command
  # @param host [String]
  def dry_run host
    $stdout << "[#{host}::echo] #{@configuration.command}\n"
  end

  private
 
  # build configuration from key/value pairs
  def manual_config key, val
    # don't send val to Configuration.dry_run
    # and only send if true
    if key.to_sym == :dry_run and val == true
      @configuration.dry_run
      return
    end
    # send configuration to Configuration
    if @configuration.respond_to?(key.to_sym)
      @configuration.send("#{key}=".to_sym, val)
      return
    end
    # send everything else to self
    self.send("#{key}=".to_sym, val)
  end
end

# configuration for {RemoteRunner}
class Configuration
  attr_writer :hosts, :username, :command, :ssh_opts, :ssh, :env, :dry_run

  def initialize
    @dry_run = false
  end

  # set @dry_run to [TrueClass]
  def dry_run
    @dry_run = true
  end

  # @return [Boolean] is it a dry run?
  def dry_run?
    @dry_run
  end

  # @return [String] command or raise error
  def command
    @command or raise "command undefined"
  end

  # @return [Array] of hosts or raise error
  def hosts
    @hosts||=[ "localhost" ]
    @hosts = [ @hosts ] if @hosts.kind_of?(String)
    raise "invalid hosts" unless @hosts.kind_of?(Array)
    @hosts
  end

  # @return [String] ssh command
  def ssh 
    @ssh||="ssh"
  end

  # @return [String] "username@"
  def username
    return '' unless @username
    return @username if @username =~ /@$/ or @username.empty?
    return "#{@username}@"
  end

  # @return [String] ssh options or blank
  def ssh_opts
    @ssh_opts||=''
  end

  # @return [String] environment or blank
  # TODO: accept hash and convert to string
  def env
    @env||=''
  end

end

