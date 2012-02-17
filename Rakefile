#--
# Copyright (c) 2009-2011 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

task :default => 'spec:run'
task 'gem:release' => 'spec:run'

$:.unshift( "lib" )
require 'tyrant_manager/version'

Bones {
  name    "tyrantmanager"
  authors "Jeremy Hinegardner"
  email   "jeremy@copiousfreetime.org"
  url     "https://github.com/copiousfreetime/tyrantmanager"
  version TyrantManager::VERSION

  ruby_opts     %w[ -w -rubygems ]
  readme_file   "README.rdoc"
  ignore_file   ".gitignore"
  history_file  "HISTORY.rdoc"

  rdoc.include << "README.rdoc" << "HISTORY.rdoc" << "LICENSE"

  summary 'A command line tool for managing Tokyo Tyrant instances.'
  description <<_
A command line tool for managing Tokyo Tyrant instances.  It allows for the
creation, starting, stopping, listing, stating of many tokyo tyrant instances
all on the same machine.  The commands can be applied to a single or multiple
instances.
_

  depend_on "loquacious"  ,"~> 1.9.1"
  depend_on "rufus-tokyo" ,"~> 1.0.7"
  depend_on "logging"     ,"~> 1.6.1"
  depend_on "main"        ,"~> 4.6.0"
  depend_on "ffi"         ,"~> 1.0.9" #unsure why this doesn't get resolved with rufus-tokyo


  depend_on "bones"       , "~> 3.7.3", :development
  depend_on "bones-rspec" , "~> 2.0.1", :development
  depend_on "rspec"       , "~> 2.8.0", :development
  depend_on "rake"        , "~> 0.9.2.2", :development

  spec.opts << "--colour" << "--format documentation"
}

