require 'test/unit'
require 'test/unit/testresult'
require 'test/unit/testcase'
require 'test/unit/ui/console/testrunner'

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
    started_old(result)
    @benchmark_times = {}
  end
  
  alias finished_old finished
  def finished(elapsed_time)
    finished_old(elapsed_time)
    output_group = @benchmark_times.sort{|a, b| b[1] <=> a[1]}
    output_group = output_group.slice(0,10) unless ENV['BENCHMARK'] == 'full'
    output_group.each do |element|
      value = element[1]
      key = element[0]
      puts(("%0.3f" % value) + " #{key}") if /^test_/.match(key)
    end
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
  end
end

end
end
end
end