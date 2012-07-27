require File.dirname(__FILE__) + '/test_helper.rb'

class TestFormat < ::Test::Unit::TestCase
  def setup
    @builder = TZTime::LocalTime::Builder.new('America/New_York')
    @time = @builder.local(2008, 4, 1, 14)
  end

  def test_time_zone
    assert_equal "EDT %Z", @time.strftime("%Z %%Z")
    assert_equal "%Z EDT", @time.strftime("%%Z %Z")
  end

  def test_meridian_indicator
    assert_equal "p %P", @time.strftime("%P %%P")
    assert_equal "%P p", @time.strftime("%%P %P")
  end
end
