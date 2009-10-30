require 'tasks/config'

#-----------------------------------------------------------------------
# Gemcutter additions to the task library
#-----------------------------------------------------------------------
namespace :dist do
  desc "Release files to gemcutter"

  task :push => :gem do
    gem_file = File.expand_path( File.join( "pkg", "#{TyrantManager::GEM_SPEC.full_name}.gem" ) )
    %x[ gem push -V #{gem_file} ].each do |line|
      puts line
    end
  end
end
