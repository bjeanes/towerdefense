desc "Restart passenger app"
task :restart do
  `touch tmp/restart.txt`
end