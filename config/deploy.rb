set :application, "towerdefense"
 
set :use_sudo, false
set :user, application
set :domain, "67.207.142.134"
 
role :app, domain
role :web, domain
role :db, domain, :primary => true
 
default_run_options[:pty] = true
 
set :scm, :git
set :repository,  "git@github.com:bjeanes/#{application}.git"
set :deploy_to, "/var/www/#{application}"
set :branch, "master"
set :deploy_via, :remote_cache
set :git_enable_submodules, 1
ssh_options[:forward_agent] = true
ssh_options[:keys] = %w(~/.ssh/id_dsa)
 
before 'deploy:cold', 'deploy:upload_database_yml'
after 'deploy:symlink', 'deploy:create_symlinks'
after 'deploy', 'deploy:start_juggernaut'
 
namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
  desc "Uploads database.yml file to shared path"
  task :upload_database_yml, :roles => :app do
    put(File.read('config/database.yml'), "#{shared_path}/database.yml", :mode => 0644)
  end
  
  desc "Symlinks database.yml file from shared folder"
  task :create_symlinks, :roles => :app do
    run "rm -drf #{current_path}/public/game"
    run "ln -s #{shared_path}/game #{current_path}/public/game"
    run "rm -f #{release_path}/config/database.yml"
    run "ln -s #{shared_path}/database.yml #{current_path}/config/database.yml"
  end
  
  desc "Start juggernaut on the server"
  task 'start_juggernaut' do
    run "cd #{current_path} && rake juggernaut:run"
  end
end
