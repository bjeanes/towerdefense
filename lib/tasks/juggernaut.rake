desc "Runs juggernaut server in background"
task 'juggernaut:run' do
  `kill \`cat tmp/pids/juggernaut.pid\``
  `#{!ENV['NO_SUDO'].nil? ? 'sudo' : ''} juggernaut -e -d -c config/juggernaut.yml`
end