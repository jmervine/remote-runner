module Remote
  class Runner

    # @return [Remote::Configuration] see {Remote::Configuration#configuration}
    attr_accessor :configuration

    # @return [Boolean] did it wait when running threaded
    # * this is mostly for testing
    attr_reader :waited # mainly for specs

    # @param opt [Hash] see {Remote::Configuration#configure}
    def initialize opt={}
      @waited = false
     
      group = opt.delete(:group)||nil
      unless group.nil?
        Remote.configure do |c|
          c.group = group
        end
      end

      file = opt.delete(:file)||nil
      Remote.configure file unless file.nil?

      if file.nil? and ENV['RR_FILE'] and File.exists?(ENV['RR_FILE'])
        Remote.configure ENV['RR_FILE']
      end

      @configuration  ||= Remote.configuration

      opt.each do |key,val|
        @configuration.send("#{key}=".to_sym, val)
      end

    end

    # run command
    def run 
      status = true
      @configuration.hosts.each do |host|
        if @configuration.dry_run?
          dry_run host
        else
          if @configuration.threaded
            thread_host(host)
            #unless thread_host(host)
              #status = false
            #end
          else
            unless run_host(host)
              status = false
            end
          end
        end
      end
      if @configuration.threaded && !@configuration.dry_run?
        Thread.list.each do |t|
          t.join unless Thread.current == t
        end
      end
      return status
    end

    protected

    # run a command on a remote host
    # @param host [String]
    def run_host host
      status  = []
      ssh     = nil 

      begin
        if @configuration.ssh_opts.empty?
          ssh = Net::SSH.start(host, @configuration.username) 
        else
          ssh = Net::SSH.start(host, @configuration.username, @configuration.ssh_opts) 
        end
      rescue SocketError
        stdputs host, :stderr, "host not found"
        return false
      end

      @configuration.commands.each do |command|
        status.push ssh_exec(ssh, host, command)
      end

      status.each do |stat|
        return false unless stat == 0
      end
      return true

    end

    # call {#run_host} using [Thread]
    # @param host [String]
    def thread_host host
      while Thread.list.count >= @configuration.max_threads do
        @waited = true # for specs
        sleep 0.1
      end
      Thread.new do
        run_host host
      end
    end

    # echo host and command
    # @param host [String]
    def dry_run host
      @configuration.commands.each do |command|
        if @configuration.verbose
          stdputs host, :command, command
        end
        stdputs host, :dry, command
      end
    end

    private
   
    def ssh_exec(ssh, host, command)
      #stdout_data = ""
      #stderr_data = ""
      exit_code = nil
      exit_signal = nil
      ssh.open_channel do |channel|
        channel.exec(command) do |ch, success|
          unless success
            stdputs host, :stderr, "FAILED: couldn't execute command (#{command})"
            return 42
          end
          if @configuration.verbose
            stdputs host, :command, command
          end
          channel.on_data do |ch,data|
            stdputs host, :stdout, data
          end
          channel.on_extended_data do |ch,type,data|
            stdputs host, :stderr, data
          end
          channel.on_request("exit-status") do |ch,data|
            exit_code = data.read_long
          end
        end
      end
      ssh.loop
      #if exit_code == 0
        #stdputs host, :stdout, "exit success"
      #else
        #stdputs host, :stderr, "exit failed(#{exit_code})"
      #end
      return exit_code
    end

    def stdputs host, stream, data
      unless data.strip.empty?
        string = data.strip

        case stream
        when :stdout
          stream_s = "out"
        when :stderr 
          stream_s = "err"
        when :command 
          stream_s = "cmd"
          stream = :stdout
        else
          stream_s = stream.to_s[0..2]
          stream = :stdout
        end

        unless @configuration.quiet
          string = "[ #{stream_s}::#{host} ] #{string}"
        end

        eval "$#{stream} << '#{string}\n'"
        #eval "$#{stream} << '[%s:%7s] %s\n' % [host,label,data.strip]"
      end
    end
  end
end

