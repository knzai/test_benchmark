require 'rubygems'
require 'test/unit'

require File.dirname(__FILE__) + "/../lib/test_benchmark"

class BenchmarkTest < Test::Unit::TestCase

  def test_basic
    assert true
  end
  
  def test_long_running
    sleep 5
  end
  
end
