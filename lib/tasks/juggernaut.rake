desc "Runs juggernaut server in background"
task 'juggernaut:run' do
  `kill \`cat tmp/pids/juggernaut.pid\` > /dev/null 2>&1`
  `juggernaut -e -d -c config/juggernaut.yml`
end