unless %w{false none}.include?(ENV['BENCHMARK'])

require 'test/unit'
require 'test/unit/testresult'
require 'test/unit/testcase'
require 'test/unit/ui/console/testrunner'

module Test
module Unit
module UI
module Console
class TestRunner
  include Loggable if const_defined?(:Loggable)
  
  alias attach_to_mediator_old attach_to_mediator
  def attach_to_mediator
    attach_to_mediator_old
    @mediator.add_listener(Test::Unit::TestSuite::STARTED, &method(:test_suite_started))
    @mediator.add_listener(Test::Unit::TestSuite::FINISHED, &method(:test_suite_finished))
  end
  
  alias started_old started
  def started(result)
    started_old(result)
    @benchmark_times = {}
  end
  
  alias finished_old finished
  def finished(elapsed_time)
    finished_old(elapsed_time)
    benchmarks = @benchmark_times.sort{|a, b| b[1] <=> a[1]}
    output_benchmarks(benchmarks, true)
    benchmarks = benchmarks.slice(0,10) unless ENV['BENCHMARK'] == 'full'
    output_benchmarks(benchmarks)
  end
  
  alias test_started_old test_started
  def test_started(name)
    test_started_old(name)
    @benchmark_times[name] = Time.now
  end
  
  alias test_finished_old test_finished
  def test_finished(name)
    test_finished_old(name)
    @benchmark_times[name] = Time.now - @benchmark_times[name]
  end
  
  def test_suite_started(name)
  end
  
  def test_suite_finished(name)
    return unless ENV['BENCHMARK'] == 'full'
    benchmarks = @benchmark_times.select{ |k,v| k.include?(name) }.sort{|a, b| b[1] <=> a[1]}
    output_benchmarks(benchmarks, false, name) unless benchmarks.length == 0
  end
  
  def format_benchmark_row(tuple)
    ("%0.3f" % tuple[1]) + " #{tuple[0]}"
  end
  
  def output_benchmarks(benchmarks, use_logger=false, name=nil)
    return if use_logger && !defined?(logger)
    if name
      header = "\nTest Benchmark Times: #{name}"
    else
      header = "\nOVERALL TEST BENCHMARK TIMES"
    end
    strings = benchmarks.map {|tuple| ("%0.3f" % tuple[1]) + " #{tuple[0]}"}
    if use_logger
      logger.debug header
      logger.debug strings.join("\n")
    else
      puts header
      puts strings
    end
  end
end

end
end
end
end

end