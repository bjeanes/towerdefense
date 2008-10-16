desc "Runs juggernaut server in background"
task 'juggernaut:run' do
  `kill \`cat tmp/pids/juggernaut.pid\``
  `sudo juggernaut -e -d -c config/juggernaut.yml`
end