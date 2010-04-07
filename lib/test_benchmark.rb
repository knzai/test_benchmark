require 'test/unit'
require 'test/unit/testresult'
require 'test/unit/testcase'
require 'test/unit/ui/console/testrunner'

class Test::Unit::UI::Console::TestRunner
  DEFAULT_DISPLAY_LIMIT = 15
  DEFAULT_SUITE_DISPLAY_LIMIT = 5
  
  @@display_limit = DEFAULT_DISPLAY_LIMIT
  @@suite_display_limit = DEFAULT_SUITE_DISPLAY_LIMIT
  
  def self.set_test_benchmark_limits(set_display_limit=DEFAULT_DISPLAY_LIMIT, set_suite_display_limit=DEFAULT_SUITE_DISPLAY_LIMIT)
    @@display_limit = set_display_limit
    @@suite_display_limit = set_suite_display_limit
  end
  
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
  
  def add_fault(fault)
    @faults << fault
    nl
    output("%3d) %s" % [@faults.length, fault.long_display])
    @already_outputted = true
  end
  
  alias started_old started
  def started(result)
    started_old(result)
    @test_benchmarks = {} 
    @suite_benchmarks = {}
  end
  
  alias finished_old finished
  def finished(elapsed_time)
    nl
    output("Finished in #{elapsed_time} seconds.")
    output(@result)
    output_benchmarks
    output_benchmarks(:suite)
    nl
    exit!(1) unless @faults.empty?
  end
  
  alias test_started_old test_started
  def test_started(name)
    test_started_old(name)
    @test_benchmarks[name] = Time.now
  end
  
  alias test_finished_old test_finished
  def test_finished(name)
    test_finished_old(name)
    @test_benchmarks[name] = Time.now - @test_benchmarks[name]
  end
  
  def test_suite_started(suite_name)
    @suite_benchmarks[suite_name] = Time.now
  end
  
  def test_suite_finished(suite_name)
    @suite_benchmarks[suite_name] = Time.now - @suite_benchmarks[suite_name]
    output_benchmarks(suite_name) if full_output?
  end
  
  @@format_benchmark_row = lambda {|tuple| ("%0.3f" % tuple[1]) + " #{tuple[0]}"}
  @@sort_by_time = lambda { |a,b| b[1] <=> a[1] }

private
  def full_output?
    ENV['BENCHMARK'] == 'full'
  end

  def select_by_suite_name(suite_name)
    if suite_name == :suite
      @suite_benchmarks.select{ |k,v| @test_benchmarks.detect{ |k1,v1| k1.include?(k) } }
    elsif suite_name
      @test_benchmarks.select{ |k,v| k.include?(suite_name) }
    else
      @test_benchmarks
    end
  end

  def prep_benchmarks(suite_name=nil)
    benchmarks = select_by_suite_name(suite_name)
    return if benchmarks.nil? || benchmarks.empty?
    benchmarks = benchmarks.sort(&@@sort_by_time)
    unless full_output?
      cutoff = (suite_name == :suite) ? @@suite_display_limit : @@display_limit
      benchmarks = benchmarks.slice(0, cutoff) 
    end
    benchmarks.map(&@@format_benchmark_row)
  end

  def header(suite_name)
    if suite_name == :suite
      "\nTest Benchmark Times: Suite Totals:\n"
    elsif suite_name
      "\nTest Benchmark Times: #{suite_name}\n"
    else
      "\nTEST BENCHMARK TIMES: OVERALL\n"
    end
  end

  def output_benchmarks(suite_name=nil)
    benchmarks = prep_benchmarks(suite_name)
    return if benchmarks.nil? || benchmarks.empty?
    output(header(suite_name) + benchmarks.join("\n") + "\n")
  end
end
