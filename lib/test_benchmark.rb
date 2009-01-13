require 'test/unit'
require 'test/unit/testresult'
require 'test/unit/testcase'
require 'test/unit/ui/console/testrunner'

module Test
module Unit
module UI
module Console

class TestRunner
  include Loggable
  
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
    logger.debug "\nOVERALL TEST BENCHMARK TIMES"
    output_group.each do |element|
      logger.debug format_benchmark_row(element)
    end    
    output_group = output_group.slice(0,10) unless ENV['BENCHMARK'] == 'full'
    puts "\nOVERALL TEST BENCHMARK TIMES"
    output_group.each do |element|
      puts format_benchmark_row(element)
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
    return unless ENV['BENCHMARK'] == 'full'
    output_group = @benchmark_times.select{ |k,v| k.include?(name) }.sort{|a, b| b[1] <=> a[1]}
    return if output_group.length == 0
    puts "\nTEST BENCHMARK TIMES: #{name}"
    output_group.each do |element|
      puts format_benchmark_row(element)
    end
  end
  
  def format_benchmark_row(array)
    ("%0.3f" % array[1]) + " #{array[0]}"
  end
  
end

end
end
end
end