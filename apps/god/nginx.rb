God.watch do |w|
  w.name = "nginx"
  w.pid_file = "/opt/nginx/logs/nginx.pid"
  w.group = "srv"

  w.interval = 30.seconds # default      
  w.start = "/opt/nginx/sbin/nginx -c /opt/nginx/conf/nginx.conf"
  w.stop = "kill `cat #{w.pid_file}`"
  w.restart = "kill -HUP `cat #{w.pid_file}`"
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds

  w.behavior(:clean_pid_file)

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:http_response_code) do |c|
      c.host = 'localhost'
      c.port = 80
      c.path = '/'
      c.timeout = 3.seconds
      c.times = [4, 5]
      c.code_is_not = 200
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
