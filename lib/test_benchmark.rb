
unless ENV['SHOW_TEST_BENCHMARK_REPORT'].blank?
  
  # EXPERIMENTAL
  # Show a report of the time each test takes to run
  class Test::Unit::TestSuite
  
    @@test_benchmarks = {}
    
    # Runs the tests and/or suites contained in this
    # TestSuite.
    def run(result, &progress_block)
      yield(STARTED, name)
      @tests.each do |test|
        start_single_test = Time.now
        test.run(result, &progress_block)
        @@test_benchmarks[test.name] = Time.now - start_single_test
        # print sprintf("#{test.name} %.3f", Time.now - start_single_test) + " "
      end
      yield(FINISHED, name)
    
      puts "\nTEST BENCHMARK REPORT"
      @@test_benchmarks.keys.sort{|a, b| @@test_benchmarks[a] <=> @@test_benchmarks[b]}.each do |key|
        value = @@test_benchmarks[key]
        puts(("%0.3f" % value) + " #{key}") if /^test_/.match(key)
      end
    end
  
  end

end

