require 'loquacious'

Loquacious::Configuration.for( "manager" ) do
  desc <<-txt
  The top directory of the manager directory.  This is set with the 
  --directory option or it can be set here"
  txt
  home     nil

  desc <<-txt
  The list of locations that contain Tyrant instances.  Each element in this array
  either a directory containing instance directories, or an instance directory itself.
  Tyrant Manager will figure out what the case is.  If this is unset, then the default
  'instances' directory below the manager's home directory is used.
  txt
  instances nil

  desc <<-txt
  Default settings for tyrant instances.  If a tyrant does not explicitly set one of 
  these configurations then the default listed here is used.  This does not list all
  of the configuration variables, only those that make sense to have defaults for.
  txt
  instance_defaults {
    desc "The number of threads to use"
    thread_count 8

    desc "Number of seconds to terminate a session request if no request is made"
    session_timeout 15

    desc "The level of logging, this can be 'debug', 'info', or 'error'"
    log_level "error"

    desc "Run daemoized"
    daemonize true

    desc <<-txt
    The size of the update log in bytes.  You may use a trailing letter to indicate
    kilobytes(k), megabytes(m), gigabytes(g), terabytes(t), exabytes(e)
    txt
    update_log_size "1g"

    desc "Use asychronous I/O when writing to the update log"
    update_log_async false

    desc <<-txt
    Forbidden protocol commands, this is the list of commands that will be denied to the client.
    The full list is:
      put putkeep putcat putshl putnr out get mget vsize iterinit iternext fwmkeys addint
      adddouble ext sync optimize vanish copy restore setmst rnum size stat misc repl slave

    There are meta lists too:

      all       : all commands
      allorg    : all tyrant binary protocol commands
      allmc     : all memecached protocol commands
      allhttp   : all http commands
      allread   : get mget vsiz iterinit iternext fwmkeys rnum size stat
      allwrite  : put putkeep putcat putshl putnr out addint adddouble vanish misc
      allmanage : sync optimize copy restore setmst

    To deny optimize vanish and slave commands the configuration would be:
      
      deny_commands [ 'vanish', 'slave', 'optimizie' ]

    txt
    deny_commands nil

    desc <<-txt
    Specifically allowed protocol commands.  This will only allow these commands.  The same
    list of commands in the deny_commands configuration is available.

    Leave this as nil to use the defaults.  To only allow the read and write commands and no
    others the configuration would be:

      allow_commands [ 'allread', 'allwrite' ]

    txt
    allow_commands nil
    
  }


end
