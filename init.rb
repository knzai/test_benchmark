if ENV['RAILS_ENV'] == 'test' && !%w{false none}.include?(ENV['BENCHMARK'])
  while (pid ||= $$).to_i > 0
    pid, *process = `ps -p #{pid} -o ppid -o args`.strip.split("\n").last.split
    @autotest ||= process.join =~ /autotest/i 
  end 

  require File.dirname(__FILE__) + "/lib/test_benchmark" unless @autotest
end
