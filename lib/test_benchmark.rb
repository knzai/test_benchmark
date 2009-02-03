unless %w{false none}.include?(ENV['BENCHMARK'])

require 'test/unit'
require 'test/unit/testresult'
require 'test/unit/testcase'
require 'test/unit/ui/console/testrunner'

class Test::Unit::UI::Console::TestRunner  
  alias attach_to_mediator_old attach_to_mediator
  # def attach_to_mediator_old
  #   @mediator.add_listener(TestResult::FAULT, &method(:add_fault))
  #   @mediator.add_listener(TestRunnerMediator::STARTED, &method(:started))
  #   @mediator.add_listener(TestRunnerMediator::FINISHED, &method(:finished))
  #   @mediator.add_listener(TestCase::STARTED, &method(:test_started))
  #   @mediator.add_listener(TestCase::FINISHED, &method(:test_finished))
  # end
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
    output_benchmarks
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
  
  def test_suite_started(suite_name)
  end
  
  def test_suite_finished(suite_name)
    output_benchmarks(suite_name) if full_output?
  end
  
  @@format_benchmark_row = lambda {|tuple| ("%0.3f" % tuple[1]) + " #{tuple[0]}"}
  @@sort_by_time = lambda { |a,b| b[1] <=> a[1] }

private
  def full_output?
    ENV['BENCHMARK'] == 'full'
  end

  def select_by_suite_name(suite_name)
    @benchmark_times.select{ |k,v| k.include?(suite_name) }
  end

  def prep_benchmarks(suite_name=nil)
    benchmarks = suite_name ? select_by_suite_name(suite_name) : @benchmark_times
    benchmarks = benchmarks.sort(&@@sort_by_time)
    benchmarks = benchmarks.slice(0,10) unless full_output?
    benchmarks
  end

  def header(suite_name)
    if suite_name
      "\nTest Benchmark Times: #{suite_name}"
    else
      "\nOVERALL TEST BENCHMARK TIMES"
    end
  end

  def output_benchmarks(suite_name=nil)
    benchmarks = prep_benchmarks(suite_name)
    return if benchmarks.empty?
    strings = benchmarks.map(&@@format_benchmark_row)
    puts header(suite_name) + "\n" + strings.join("\n") + "\n\n"
  end
end

end