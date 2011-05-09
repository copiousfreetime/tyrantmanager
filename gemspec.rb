require 'rubygems'
require 'tyrant_manager/version'
require 'tasks/config'

TyrantManager::GEM_SPEC = Gem::Specification.new do |spec|
  proj = Configuration.for('project')
  spec.name         = proj.name
  spec.version      = TyrantManager::VERSION
  
  spec.author       = proj.author
  spec.email        = proj.email
  spec.homepage     = proj.homepage
  spec.summary      = proj.summary
  spec.description  = proj.description
  spec.platform     = Gem::Platform::RUBY

  
  pkg = Configuration.for('packaging')
  spec.files        = pkg.files.all
  spec.executables  = pkg.files.bin.collect { |b| File.basename(b) }

  # add dependencies here
  spec.add_dependency( "loquacious", "~> 1.6.4")
  spec.add_dependency( "rufus-tokyo", "~> 1.0.1")
  spec.add_dependency( "logging", "~> 1.4.3" )
  spec.add_dependency( "main", "~> 4.2.0" )
  spec.add_dependency( 'ffi', "~> 1.0.7" ) # unsure why this doesn't get resolved with rufus-tokyo

  # development dependencies
  spec.add_development_dependency("configuration", "~> 1.1.0")
  spec.add_development_dependency( "rake", "~> 0.8.3")

  if ext_conf = Configuration.for_if_exist?("extension") then
    spec.extensions << ext_conf.configs
    spec.extensions.flatten!
  end
  
  if rdoc = Configuration.for_if_exist?('rdoc') then
    spec.has_rdoc         = true
    spec.extra_rdoc_files = pkg.files.rdoc
    spec.rdoc_options     = rdoc.options + [ "--main" , rdoc.main_page ]
  else
    spec.has_rdoc         = false
  end 

  if test = Configuration.for_if_exist?('testing') then
    spec.test_files       = test.files
  end 

  if rf = Configuration.for_if_exist?('rubyforge') then
    spec.rubyforge_project  = rf.project
  end 

end
