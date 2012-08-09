require 'spec_helper'

#Usage: remoterun [options]

    #-f, --file [file_path]           config file
    #-g, --group [config_group]       config group (default: 'default')
    #-r, --hosts [host1, host2]       comma delimited list of remote hosts (default: 'localhost')
    #-c, --commands [cmd1, cmd2]      comma delimited list of commands
    #-u, --username [username]        ssh username
    #-i, --ssh-key [file_path]        ssh key path
    #-t, --threaded                   run hosts threaded
    #-m, --max-threads [thead count]  max threads (default: 5)
    #-v, --verbose                    Include commands being run.
    #-q, --quiet                      Do not include host and output stream.
    #-h, --help                       Show this message
        #--version                    Show version


describe "bin/remoterun" do
  it "no options" do 
    %x{ ./bin/remoterun -h }.strip.should match /^Usage/  
  end

  it "-f, --file [file_path]" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml }.strip.should match /^\[ dry::localhost \] hostname/  
    %x{ ./bin/remoterun --file ./spec/dummy_config.yml }.strip.should match /^\[ dry::localhost \] hostname/  
  end

  it "-g, --group [config_group]" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -g default }.strip.should match /^\[ dry::localhost \] hostname/  
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --group default }.strip.should match /^\[ dry::localhost \] hostname/  
  end

  it "-r, --hosts [host1, host2]" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -r #{`hostname`.strip} }.strip.should match /^\[ dry::#{`hostname`.strip} \] hostname/  
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --hosts #{`hostname`.strip} }.strip.should match /^\[ dry::#{`hostname`.strip} \] hostname/  
  end

  it "-c, --commands [cmd1, cmd2]" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -c "echo hello" }.strip.should match /^\[ dry::localhost \] echo hello/  
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --commands "echo hello" }.strip.should match /^\[ dry::localhost \] echo hello/  
  end

  it "-u, --username [username]" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -u jmervine }.strip.should match /^\[ dry::localhost \] hostname/
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --username jmervine }.strip.should match /^\[ dry::localhost \] hostname/
  end

  it "-i, --ssh-key [file_path]" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -i ~/.ssh/id_rsa }.strip.should match /^\[ dry::localhost \] hostname/
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --ssh-key ~/.ssh/id_rsa }.strip.should match /^\[ dry::localhost \] hostname/
  end

  it "-t, --threaded" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -t }.strip.should match /^\[ dry::localhost \] hostname/
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --threaded }.strip.should match /^\[ dry::localhost \] hostname/
  end

  it "-m, --max-threads [thread count]" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -m 5 }.strip.should match /^\[ dry::localhost \] hostname/
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --max-threads 5 }.strip.should match /^\[ dry::localhost \] hostname/
  end

  it "-v, --verbose" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -v }.strip.should match /^\[ cmd::localhost \] hostname/
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --verbose }.strip.should match /^\[ cmd::localhost \] hostname/
  end

  it "-q, --quiet" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -q }.strip.should match /^hostname/
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --quiet }.strip.should match /^hostname/
  end

  it "-p, --pretend" do
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml -p }.strip.should match /^\[ dry::localhost \] hostname/
    %x{ ./bin/remoterun -f ./spec/dummy_config.yml --pretend }.strip.should match /^\[ dry::localhost \] hostname/
  end

  it "-h, --help" do
    %x{ ./bin/remoterun -h }.strip.should match /^Usage/  
    %x{ ./bin/remoterun --help }.strip.should match /^Usage/  
  end

  it "--version" do 
    %x{ ./bin/remoterun --version }.strip.should match /^remoterun #{Remote::VERSION}/  
  end
end

