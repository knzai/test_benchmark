require 'test/unit'
require 'test/unit/testresult'
require 'test/unit/testcase'
require 'test/unit/ui/console/testrunner'

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
    end
    yield(FINISHED, name)
  end

end

module Test
module Unit
module UI
module Console

class TestRunner
  
  alias attach_to_mediator_old attach_to_mediator
  def attach_to_mediator
    attach_to_mediator_old
    @mediator.add_listener(Test::Unit::TestSuite::STARTED, &method(:test_suite_started))
    @mediator.add_listener(Test::Unit::TestSuite::FINISHED, &method(:test_suite_finished))
  end
  
  alias started_old started
  def started(result)
    started_old
  end
  
  alias finished_old finished
  def finished(elapsed_time)
    finished_old
    @@test_benchmarks = Test::Unit::TestSuite.send(:class_variable_get, '@@test_benchmarks')
    @@test_benchmarks.keys.sort{|a, b| @@test_benchmarks[a] <=> @@test_benchmarks[b]}.each do |key|
      value = @@test_benchmarks[key]
      puts(("%0.3f" % value) + " #{key}") if /^test_/.match(key)
    end
  end
  
  alias test_started_old test_started
  def test_started(name)
    test_started_old
  end
  
  alias test_finished_old test_finished
  def test_finished(name)
    test_finished
  end
  
  def test_suite_started(name)
    #puts name
  end
  
  def test_suite_finished(name)
    #puts Test::Unit::TestSuite.send :class_variable_get, '@@test_benchmarks'
  end
end

end
end
end
end