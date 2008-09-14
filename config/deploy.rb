set :application, "towerdefense"
 
set :use_sudo, false
set :user, application
set :domain, "#{application}.com.au"
 
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
 
before 'deploy:cold', 'deploy:upload_database_yml'
after 'deploy:cold', 'deploy:cluster_configure'
after 'deploy:symlink', 'deploy:create_symlinks'
 
namespace :deploy do
  task :cluster_configure do
    run "cd #{current_path} && mongrel_rails cluster::configure -e production -p 10000 -N 3 -c #{current_path} -a 127.0.0.1 --user #{user} --group #{user} -C #{shared_path}/mongrel_cluster.yml"
  end
  
  desc "Restart mongrel cluster"
  task :restart do
    stop
    start
  end
  
  desc "Stop mongrel cluster"
  task :stop do
    run "cd #{current_path} && sudo /usr/bin/mongrel_rails cluster::stop -C #{shared_path}/mongrel_cluster.yml"
  end
  
  desc "Start mongrel cluster"
  task :start do
    run "cd #{current_path} && sudo /usr/bin/mongrel_rails cluster::start -C #{shared_path}/mongrel_cluster.yml"
  end
  
  task :upload_database_yml do
    put(File.read('config/database.yml'), "#{shared_path}/database.yml", :mode => 0666)
  end
  
  task :create_symlinks do
    run "rm -drf #{release_path}/public/uploads"
    # run "ln -s #{shared_path}/uploads #{release_path}/public/uploads"
    run "rm -f #{release_path}/config/database.yml"
    run "ln -s #{shared_path}/database.yml #{release_path}/config/database.yml"
  end
end