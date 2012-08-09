module Remote
  # configuration for {Remote::Runner}
  class Configuration

    attr_writer :hosts, :username, :commands, :ssh_opts, :dry_run, :threaded, :max_threads, :group

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

    # @return [String] configuration file grouping
    def group
      @group ||= "default"
    end

    # @return [String] command or raise error
    def commands
      @commands or raise "commands undefined"
      @commands = [ @commands ] if @commands.kind_of?(String)
      raise "invalid commands" unless @commands.kind_of?(Array)
      @commands
    end

    # @return [Array] of hosts or raise error
    def hosts
      @hosts||=[ "localhost" ]
      @hosts = [ @hosts ] if @hosts.kind_of?(String)
      raise "invalid hosts" unless @hosts.kind_of?(Array)
      @hosts
    end

    # @return [String] username or nil
    def username
      @username||=%x{whoami}.strip
    end

    # @return [Hash] ssh options
    def ssh_opts
      @ssh_opts||={}
    end

    # @return [Fixnum] max threads
    def max_threads
      @max_threads ||= 5
    end

    # @return [Boolean] threaded?
    def threaded
      @threaded ||= false
    end
  end
end
