every 1.minute do
   rake "server:check_status", :output => {:error => 'log/error.log', :standard => 'log/cron.log'}
   rake "container:check_status"
end
