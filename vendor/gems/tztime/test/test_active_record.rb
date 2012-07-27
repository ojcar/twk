require File.dirname(__FILE__) + '/test_helper.rb'
require 'tztime/activerecord'

class TestActiveRecord < ::Test::Unit::TestCase
  def setup
    ActiveRecord::Base.establish_connection(
      :adapter => "sqlite3",
      :database  => "./test.sqlite3"
    )
    ActiveRecord::Base.connection.execute("CREATE TABLE	settings (id PRIMARY KEY, time_zone_name VARCHAR, created_at DATETIME);")
    @setting = Setting.create :time_zone_name => 'America/Los_Angeles'
  end

  def teardown
    ActiveRecord::Base.remove_connection
    File.delete("./test.sqlite3")
  end
  
  def test_created_at_is_utc
    assert_equal "UTC", @setting.created_at.zone
  end

  def test_local_created_at_is_pdt
    assert_equal "PDT", @setting.local_created_at.zone
  end

  def test_local_get_now_is_utc
    assert_equal "UTC", @setting.get_now.zone
  end

  def test_local_get_now_is_pdt
    assert_equal "PDT", @setting.local_get_now.zone
  end

  def test_local_get_now_is_local_time
    assert_equal TZTime::LocalTime, @setting.local_get_now.class
  end

  def test_accessor_name
    assert @setting.respond_to?(:time_builder)
  end

  def test_builder_time_zone
    assert_equal :PDT, @setting.time_builder.now.time_zone_abbreviation
  end

  def test_builder_time
    assert_equal 4, @setting.time_builder.utc(2008, 3, 1, 12).hour
  end

  def test_assign_builder_object
    @setting.time_builder = TZTime::LocalTime::Builder.new('America/Denver')
    assert_equal 'America/Denver', @setting.time_zone_name
  end
end

class Setting < ActiveRecord::Base
  acts_as_local_time :time_zone_field => :time_zone_name,
		     :time_builder_accessor => :time_builder

  def get_now
    Time.now
  end
end
