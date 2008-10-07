desc "Runs juggernaut server in background"
task 'juggernaut:run' do
  `sudo juggernaut -d -c config/juggernaut.yml`
end