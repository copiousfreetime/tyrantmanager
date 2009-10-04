
require 'tasks/config'    
gem 'gemcutter'
require 'rake/gemcutter_pushtask'

#-----------------------------------------------------------------------
# Gemcutter additions to the task library
#-----------------------------------------------------------------------
namespace :dist do
  desc "Release files to gemcutter"

  GemCutter::Rake::PushTask.new do |t|
    t.gem_file = File.expand_path( File.join( "pkg", "#{TyrantManager::GEM_SPEC.full_name}.gem" ) )
  end

  task :push => :gem

end
