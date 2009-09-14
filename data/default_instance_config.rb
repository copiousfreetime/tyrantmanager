require 'rubygems'
require 'loquacious'

# 
# The configuration for the <%= instance_name %> tokyo tyrant instance
#
# The options available in the instance_defaults section of the manager
# configuration are also able to be set here.
#
Loquacious::Configuration.for( "<%= instance_name %>" ) do

  desc "The hostname this instance will listen on. The default is all"
  host "0.0.0.0"

  desc "The port this tyrant will listen on.  The default is 1978"
  port 1978

  desc <<-txt
  The type of database this instance will be.  Options are:
  |    memory-hash - an in memory hash database
  |    memory-tree - an in memory B+ tree database
  |    hash        - an on disk hash database
  |    tree        - an on disk B+ tree database
  |    fixed       - an on disk fixed length database
  |    table       - an on disk table database
  txt
  type "hash"

  desc <<-txt
  Mode of the server in relation to the database.  It can be a combination of 
  the following:
  |    w - it is a database writer
  |    r - it is a database reader
  |    c - it creates the database if it does not exist
  |    t - it truncates the database if it does exist
  |    e - do not lock the database when doing operations
  |    f - use a non-blocking lock when doing operations
  txt
  mode "wc"
  

  desc <<-txt
  The options for data stored in the database.  They include one of the 
  compression options:
  |    d - Deflate
  |    b - BZIP2
  |    t - TCBS
  and 
  |    l - allow the database to be larger than 2GB
  txt
  opts "ld"

  desc <<-txt
  Tuning parameters.  Each of these alters a tuning parameter on the database.
  Not all of them are applicable to all database types
  txt

  tuning_params {
    desc <<-txt
    The number of elements in the bucket array.  Supported in hash, B+ tree
    and table databases.  It is also used in the in-memory hash database.
    It should be between 1 and 4 times the number of all records to be stored.
    txt
    bnum nil

    desc <<-txt
    The maximum number of records to store in the database.  This is only
    used in the in-memory databases.
    txt
    capnum nil

    desc <<-txt
    The maximum amount of memory to use in the server.  This is only used
    in the in-memory databases.
    txt
    capsize nil

    desc <<-txt
    Aligment power.  The byte alignment of records.  This specifies a power 
    of two.  The default value is 4 meaning that all records are aligned on 
    16 byte boundaries.

    This applies to on disk Hash, B+ tree and Table databases.
    txt
    apow nil

    desc <<-txt
    Free block pool power.  This is the maximum number of elements in the free
    block pool as a power of 2.  The default is 10 meaning that there are a 
    maximum of 1024 free blocks.
    
    This applies to on disk hash, B+ tree and Table databases.
    txt
    fpow nil

    desc <<-txt
    The maximum number of records to be cached.  If set to 0 or less then
    the cache is disabled.  That is the default.

    This applies to on disk Hash and Table databases.
    txt
    rcnum nil

    desc <<-txt
    The size of the memory mapped region.  By default this is 64 megabytes.

    This applies to on disk Hash, B+ tree and Table databases.
    txt
    xmsiz

    desc <<-txt
    Auto defragmentation configuration.  This controls how the automatic
    defragmentation of databases is preformed.  It is the 'step' 
    number.  It is off by default.

    This applies to on disk Hash, B+ tree and Table databases.
    txt
    dfunit nil

    desc <<-txt
    The maximum number of leaf nodes to be cached.  The default is 4096.

    This applies to B+ tree and Table databses
    txt
    lcnum nil

    desc <<-txt
    The maximum number of non-leaf nodes to be cached.  The default is 512.
  
    This applies to B+ tree and Table databses
    txt
    ncnum nil

    desc <<-txt
    The number of members in each leaf page.  The default is 128.

    This applies to B+ tree databases.
    txt
    lmemb nil

    desc <<-txt
    The number of members in each non-leaf page.  The default is 128.

    This applies to B+ tree databases.
    txt
    nmemb nil

    desc <<-txt
    The width of the value of each record in a fixed length database.  
    The default is 255.
    txt
    width nil

    desc <<-txt
    The file size limit of the fixed database file.  The default is 256 MB.
    txt
    limsiz nil
 
  }

  desc <<-txt
  Column index configuration.  This is in the format of 'column_name' 'index type'
  Tuning parameters.  Each of these alters a tuning parameter on the database.

  Indexes only apply to databases of type 'table'.  A column may have only one 
  index.

  The available index types are:
  |  lexical   - lexical string
  |  decimal   - decimal string
  |  token     - token inverted index
  |  qgram     - q-gram inverted index
  |  optimize  - the index is optimize
  |  void      - the index is removed
  txt

  indexes {
    # my_col [ "lexical" | "decimal" | "token" | "qgram" | "optimize" | "void" ]
  }


  desc <<-txt
  The directory holding the database file.  By default this is relative
  to the instance directory.  If you want to put it somewhere else, then
  put the full path here.
  txt
  data_dir "data"

  desc <<-txt
  The directory holding the update logs.  By default this is relative
  to the instance directory.  If you want to put it somewhere else, then
  put the full path here.
  txt
  ulog_dir "ulog"


  desc <<-txt
  The pid file location.  By default this is relative to the instance
  directory.  If you want it place somewhere else, then put the full 
  path here.
  txt
  pid_file "<%= instance_name %>.pid"


  desc <<-txt
  The log file location.  By default this is relative to the instance
  directory.  If you want it place somewhere else, then put the full 
  path here.
  txt
  log_file "log/<%= instance_name %>.log"


  desc <<-txt
  If this instance is to replicate the data from another instance then
  set that instances host here.
  txt
  master_server nil

  desc <<-txt
  If this instance is to replicate the data from another instance then
  set that instances port here.
  txt
  master_port nil

  desc <<-txt
  This is the server id of this instance when it is part of a replication.
  This must be set, and it must be unique within the set of hosts doing
  replication.
  txt
  server_id nil

  desc <<-txt
  If this server is replicating data from a master, then it must have
  this set to the location of a replication timestamp file.  The 
  default is relative to the instance directory.
  txt
  replication_timestamp_file "<%= instance_name %>.rts"

  desc <<-txt
  The name of a file to load as a lua extension.  By default this 
  is relative to the root of the instance directory.  This file will
  only be loaded if it exists.

  If this is set to a value and the file does not exist, a WARN message
  is printed to the log.
  txt
  lua_extension_file "lua/<%= instance_name %>.lua"

  desc <<-txt
  You may specify a lua function and a periodicity in which it is to
  be called.  This lua function must be available from within the
  lua_extension_file that is loaded.

  The periodicity is really the time to wait between calls.
  txt
  periodic_command {
    desc "The function to call"
    name nil

    desc "how often to call"
    period nil
  }
end

if $0 == __FILE__ then
  help = Loquacious::Configuration.help_for("<%= instance_name %>", :colorize => true)
  help.show :values => true
end
