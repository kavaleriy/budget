worker_processes Integer(ENV["WEB_CONCURRENCY"] || 2)
timeout 15
preload_app false


# Listen on unix socket
pid "tmp/pids/unicorn-openbudget.pid"
listen "/usr/share/nginx/html/unicorn.budget.sock"



before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end


  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection
end
