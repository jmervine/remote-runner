# Remote::Runner

* [doc](http://rubyops.github.com/remote_runner/doc/)
* [cov](http://rubyops.github.com/remote_runner/coverage/)


# Usage

Documentation in progress.

## Remote::Runner

See [Remote::Configuration](#Remote__Configuration) for configuration examples.

    runner = Remote::Runner.new( ... configuration ... )

    runner.configuration.commands = "hostname"
    runner.run

    runner.configuration.commands = "(ps aux | grep nginx > /dev/null) && echo true"
    runner.run

    # or
    Remote::Runner.new( ... configuration .. ).run


## Remote::Configuration

Configuration can be set a number of ways:

    Remote.configure("./path/to/config.yml")

    # and/or via a block
    Remote.configure do |conf|
      conf.hosts      = [ "host1", "host2" ]
      conf.commands   = [ "command1", "command2" ]
      ...
    end

    # and/or together
    Remote.configure("./path/to/config.yml") do |conf|
      conf.hosts      = [ "host1", "host2" ]
      conf.commands   = [ "command1", "command2" ]
      ...
    end

    # or through Remote::Runner.new
    runner = Remote::Runner.new( file: "./path/to/config.yml", hosts: ... )

### Configuration groups

Configuration.group must always be set programmatically, as it determines which section of the configuration file to be read.

    Remote.configuration.group = "mygroup"

    # or via a block
    Remote.configure do |conf|
      conf.group = "mygroup"
    end

    # or 
    runner = Remote::Runner.new( group: "mygroup" )

### ssh\_opts valid params

* :auth_methods => an array of authentication methods to try
* :compression => the compression algorithm to use, or true to use whatever is supported.
* :compression_level => the compression level to use when sending data
* :config => set to true to load the default OpenSSH config files (~/.ssh/config, /etc/ssh_config), or to false to not load them, or to a file-name (or array of file-names) to load those specific configuration files. Defaults to true.
* :encryption => the encryption cipher (or ciphers) to use
* :forward_agent => set to true if you want the SSH agent connection to be forwarded
* :global_known_hosts_file => the location of the global known hosts file. Set to an array if you want to specify multiple global known hosts files. Defaults to %w(/etc/ssh/known_hosts /etc/ssh/known_hosts2).
* :hmac => the hmac algorithm (or algorithms) to use
* :host_key => the host key algorithm (or algorithms) to use
* :host_key_alias => the host name to use when looking up or adding a host to a known_hosts dictionary file
* :host_name => the real host name or IP to log into. This is used instead of the host parameter, and is primarily only useful when specified in an SSH configuration file. It lets you specify an “alias”, similarly to adding an entry in /etc/hosts but without needing to modify /etc/hosts.
* :kex => the key exchange algorithm (or algorithms) to use
* :keys => an array of file names of private keys to use for publickey and hostbased authentication
* :key_data => an array of strings, with each element of the array being a raw private key in PEM format.
* :keys_only => set to true to use only private keys from keys and key_data parameters, even if ssh-agent offers more identities. This option is intended for situations where ssh-agent offers many different identites.
* :logger => the logger instance to use when logging
* :paranoid => either true, false, or :very, specifying how strict host-key verification should be
* :passphrase => the passphrase to use when loading a private key (default is nil, for no passphrase)
* :password => the password to use to login
* :port => the port to use when connecting to the remote host
* :properties => a hash of key/value pairs to add to the new connection’s properties (see Net::SSH::Connection::Session#properties)
* :proxy => a proxy instance (see Proxy) to use when connecting
* :rekey_blocks_limit => the max number of blocks to process before rekeying
* :rekey_limit => the max number of bytes to process before rekeying
* :rekey_packet_limit => the max number of packets to process before rekeying
* :timeout => how long to wait for the initial connection to be made
* :user => the user name to log in as; this overrides the user parameter, and is primarily only useful when provided via an SSH configuration file.
* :user_known_hosts_file => the location of the user known hosts file. Set to an array to specify multiple user known hosts files. Defaults to %w(~/.ssh/known_hosts ~/.ssh/known_hosts2).
* :verbose => how verbose to be (Logger verbosity constants, Logger::DEBUG is very verbose, Logger::FATAL is all but silent). Logger::FATAL is the default. The symbols :debug, :info, :warn, :error, and :fatal are also supported and are translated to the corresponding Logger constant.

> from: http://net-ssh.github.com/ssh/v2/api/classes/Net/SSH.html#M000002

### load\_config( YAML file ) format example

    ---
    default:
      max_threads: 10
      threaded: true
      dry_run: true
      username: jmervine
      hosts:
        - localhost
      commands: 
        - hostname
      ssh_opts: 
        forward_agent: true
        :keys: 
          - "~/.ssh/id_rsa"

## Command Line Examples

    $ remoterun -h
    Usage: remoterun [options]

        -f, --file [file_path]           config file
        -g, --group [config_group]       config group (default: 'default')
        -r, --hosts [host1, host2]       comma delimited list of remote hosts (default: 'localhost')
        -c, --commands [cmd1, cmd2]      comma delimited list of commands
        -u, --username [username]        ssh username
        -i, --ssh-key [file_path]        ssh key path
        -t, --threaded                   run hosts threaded
        -m, --max-threads [thead count]  max threads (default: 5)
        -h, --help                       Show this message
            --version                    Show version

    $ remoterun -f ./path/to/file.yml "ps aux | grep unicorn"

    $ remoterun -r localhost -c "ps aux | grep unicorn","ps aux | grep nginx" -r localhost,www.example.com -i "~/.ssh/foo_rsa"

## Environment: RR_FILE

In addition to passing a file via your environment using RR\_FILE.

   $ export RR_FILE=/path/to/config.yml 
