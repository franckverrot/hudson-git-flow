$:<< '.'
%w( rubygems open-uri net/http net/https nokogiri logger yaml json git rest-client lib/api).each do |lib| 
  require lib
end 

begin
  require 'rspec/core/rake_task'

  desc "Run specs"
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = %w(-fs --color)
    t.ruby_opts  = %w(-w)
  end
rescue LoadError
  task :spec do
    abort "Run `gem install rspec` to be able to run specs"
  end
end

task :default => 'api:jobs:add'

Api.config = 'lib/config/config.example.yml'
namespace :api do
  
  namespace :branches do
    desc 'lists github feature branches'
    task :github_feature do
      puts Api.github_feature_branches
    end   
  end

  namespace :jobs do
    desc 'lists all jobs'
    task :all do
      puts Api.job_names
    end
    
    desc 'lists hudson feature branch jobs'
    task :hudson_feature do
      puts Api.hudson_feature_jobs
    end

    desc 'discover and add any new feature branches as hudson jobs'
    task :add do
      if Api.new_branches.any?
         puts "adding feature branches to hudson" && Api.add_branches!
      else
        puts "no new feature branches"
      end
    end 
  end

  namespace :build do
    warning = lambda do
      puts "requires $> rake task[job_name], choose:"
      Rake::Task['api:jobs:all'].invoke && exit
    end
    
    desc "trigger a build for a JOB, requires job name"
    task :trigger, :job do |t,args|
      warning.call unless args.any?
      puts 'triggered.' if Api.build(args.job)
    end
  
    %w( successful stable failed ).each do |type|
      desc "puts status, there are three types: successful, stable, & failed. requires job name"
      name = :"last_#{type}"
      task name, :job do |t,args|
        warning.call unless args.any?
        Api.send(name, args.job) 
      end      
    end
  end

end
  
