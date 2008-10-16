desc "Runs juggernaut server in background"
task 'juggernaut:run' do
  `sudo juggernaut -e -d -c config/juggernaut.yml`
end