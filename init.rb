if ENV['RAILS_ENV'] == 'test' && !%w{false none}.include?(ENV['BENCHMARK'])
  processes = "ruby"
  begin
    pgid = `ps -p #{$$} -o pgid`.split("\n").last
    processes = `ps -o command -g #{pgid}`
  rescue StandardError;
  end
  require File.dirname(__FILE__) + "/lib/test_benchmark" unless processes =~ /autotest|textmate|watch/i
end