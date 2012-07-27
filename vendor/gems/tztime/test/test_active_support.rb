require File.dirname(__FILE__) + '/test_helper.rb'
require 'active_support'

class TestActiveSupport < ::Test::Unit::TestCase
  TimeZone.all.each do |tz|
    def_name = tz.name.gsub(/[\s()'&-]+/, '_').gsub('.', '').downcase
    class_eval <<-EOF
      def test_#{def_name}
	tz = TZTime::LocalTime::Builder.get_time_zone(%q[#{tz.name}])
	assert_not_nil tz, %q[#{tz.to_s} does not have a conversion]
      end
    EOF
  end
end
