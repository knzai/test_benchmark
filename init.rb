if ENV['RAILS_ENV'] == "test" && !%w{false none}.include?(ENV['BENCHMARK'])
  require File.dirname(__FILE__) + "/lib/test_benchmark"
end