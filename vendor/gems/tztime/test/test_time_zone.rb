require File.dirname(__FILE__) + '/test_helper.rb'

class TestTimeZone < ::Test::Unit::TestCase
  include TZTime::TimeZoneElement

  def test_offset_edt_dst
    self.time_zone = 'America/New_York'
    time = local_time_builder.local(2008, 6, 1)
    assert_equal(-14400, time.time_zone_offset)
  end

  def test_offset_edt_no_dst
    self.time_zone = 'America/New_York'
    time = local_time_builder.local(2008, 1, 1)
    assert_equal(-18000, time.time_zone_offset)
  end

  def test_offset_pst_dst
    self.time_zone = 'America/Los_Angeles'
    time = local_time_builder.local(2008, 6, 1)
    assert_equal(-25200, time.time_zone_offset)
  end

  def test_offset_pst_no_dst
    self.time_zone = 'America/Los_Angeles'
    time = local_time_builder.local(2008, 1, 1)
    assert_equal(-28800, time.time_zone_offset)
  end

  def test_time_zone_abbreviation_est
    self.time_zone = 'America/New_York'
    time = local_time_builder.local(2007, 12, 16)
    assert_equal(:EST, time.time_zone_abbreviation)
  end

  def test_time_zone_abbreviation_edt
    self.time_zone = 'America/New_York'
    time = local_time_builder.local(2008, 4, 16)
    assert_equal(:EDT, time.time_zone_abbreviation)
  end

  def test_time_zone_abbreviation_pst
    self.time_zone = 'America/Los_Angeles'
    time = local_time_builder.local(2007, 12, 16)
    assert_equal(:PST, time.time_zone_abbreviation)
  end

  def test_time_zone_abbreviation_pdt
    self.time_zone = 'America/Los_Angeles'
    time = local_time_builder.local(2008, 4, 16)
    assert_equal(:PDT, time.time_zone_abbreviation)
  end

  def test_at_local
    self.time_zone = 'America/Los_Angeles'
    time = Time.local(2008, 4, 10, 19, 25)
    assert_equal 19, local_time_builder. at_local(time).hour
  end

  def test_at_utc
    self.time_zone = 'America/Los_Angeles'
    time = Time.local(2008, 4, 10, 19, 25)
    assert_equal 12, local_time_builder.at_utc(time).hour
  end

  def test_convert
    self.time_zone = 'America/Los_Angeles'
    time = Time.utc(2008, 4, 10, 19, 25)
    assert_equal 12, local_time_builder.convert(time).hour
  end

  def test_convert_explicit
    self.time_zone = 'America/Los_Angeles'
    time = Time.utc(2008, 4, 10, 19, 25)
    assert_equal 16, local_time_builder.convert(time, 'America/New_York').hour
  end
end
