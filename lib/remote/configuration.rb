module Remote
  # configuration for {Remote::Runner}
  class Configuration
    attr_writer :hosts, :username, :commands, :ssh_opts, :env, :dry_run, :threaded, :max_threads, :group

    # Accepts [Hash] with the follow params:
    # * :auth_methods => an array of authentication methods to try
    # * :compression => the compression algorithm to use, or true to use whatever is supported.
    # * :compression_level => the compression level to use when sending data
    # * :config => set to true to load the default OpenSSH config files (~/.ssh/config, /etc/ssh_config), or to false to not load them, or to a file-name (or array of file-names) to load those specific configuration files. Defaults to true.
    # * :encryption => the encryption cipher (or ciphers) to use
    # * :forward_agent => set to true if you want the SSH agent connection to be forwarded
    # * :global_known_hosts_file => the location of the global known hosts file. Set to an array if you want to specify multiple global known hosts files. Defaults to %w(/etc/ssh/known_hosts /etc/ssh/known_hosts2).
    # * :hmac => the hmac algorithm (or algorithms) to use
    # * :host_key => the host key algorithm (or algorithms) to use
    # * :host_key_alias => the host name to use when looking up or adding a host to a known_hosts dictionary file
    # * :host_name => the real host name or IP to log into. This is used instead of the host parameter, and is primarily only useful when specified in an SSH configuration file. It lets you specify an “alias”, similarly to adding an entry in /etc/hosts but without needing to modify /etc/hosts.
    # * :kex => the key exchange algorithm (or algorithms) to use
    # * :keys => an array of file names of private keys to use for publickey and hostbased authentication
    # * :key_data => an array of strings, with each element of the array being a raw private key in PEM format.
    # * :keys_only => set to true to use only private keys from keys and key_data parameters, even if ssh-agent offers more identities. This option is intended for situations where ssh-agent offers many different identites.
    # * :logger => the logger instance to use when logging
    # * :paranoid => either true, false, or :very, specifying how strict host-key verification should be
    # * :passphrase => the passphrase to use when loading a private key (default is nil, for no passphrase)
    # * :password => the password to use to login
    # * :port => the port to use when connecting to the remote host
    # * :properties => a hash of key/value pairs to add to the new connection’s properties (see Net::SSH::Connection::Session#properties)
    # * :proxy => a proxy instance (see Proxy) to use when connecting
    # * :rekey_blocks_limit => the max number of blocks to process before rekeying
    # * :rekey_limit => the max number of bytes to process before rekeying
    # * :rekey_packet_limit => the max number of packets to process before rekeying
    # * :timeout => how long to wait for the initial connection to be made
    # * :user => the user name to log in as; this overrides the user parameter, and is primarily only useful when provided via an SSH configuration file.
    # * :user_known_hosts_file => the location of the user known hosts file. Set to an array to specify multiple user known hosts files. Defaults to %w(~/.ssh/known_hosts ~/.ssh/known_hosts2).
    # * :verbose => how verbose to be (Logger verbosity constants, Logger::DEBUG is very verbose, Logger::FATAL is all but silent). Logger::FATAL is the default. The symbols :debug, :info, :warn, :error, and :fatal are also supported and are translated to the corresponding Logger constant.
    # from: http://net-ssh.github.com/ssh/v2/api/classes/Net/SSH.html#M000002 
    #
    attr_writer :ssh_opts

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
      @username||nil
      #return '' unless @username
      #return @username if @username =~ /@$/ or @username.empty?
      #return "#{@username}@"
    end

    # @return [Hash] ssh options or empty 
    #
    def ssh_opts
      @ssh_opts||={}
    end

    # @return [String] environment or blank
    # TODO: accept hash and convert to string
    def env
      @env||=''
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
