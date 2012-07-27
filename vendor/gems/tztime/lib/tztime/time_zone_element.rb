# This module is intented to be included into classes that need to store and
# access time zones (TZInfo time zone definition) and local time builders
# (TZTime::LocalTime::Builder). It adds a method for assigning a time zone
# to the instance. A LocalTime::Builder is created when a time zone is set.
# The builder is used to generate LocalTime instances in the specified time zone.
#
# === Usage
# Add to any class:
#   class SomeClass
#     include TZTime::TimeZoneElement
#   end
#
# Create an instance of the class and assign a time zone:
#   sc = SomeClass.new
#   sc.time_zone = 'America/New_York'
#
# or use Rails style time zone names:
#   sc.time_zone = 'Eastern Time (US & Canada)
#
# or use a TZInfo::TimeZone instance:
#   time_zone = TZInfo::Timezone.get('America/New_York')
#   sc.time_zone = time_zone
#
# Now the instance can be used to generate times:
#   puts sc.time_zone_builder.now     # => 2008-03-31 21:27:19 EDT
#   puts sc.time_zone_builder.today   # => 2008-03-31 00:00:00 EDT
#   puts sc.time_zone_builder.now.utc # => Tue Apr 01 01:27:19 UTC 2008
module TZTime::TimeZoneElement
  # retrieves the TZTime::LocalTime::Builder instance or +nil+.
  def local_time_builder
    return @local_time_builder if defined?(@local_time_builder)
    reset_local_time_builder!
  end
  
  # Assigns a new TZTime::LocalTime:Builder instance. This will also change
  # the +time_zone+ and +time_zone_name+ values.
  def local_time_builder=(value)
    @local_time_builder = value
  end
  
  # Retrieves the full name of the time zone.
  def time_zone_name
    local_time_builder.time_zone_name
  end
  
  # Retrieves the current time zone definition.
  def time_zone
    local_time_builder.time_zone
  end
  
  # Sets the time zone for the parser. This is used to calculate offset values
  # for the dates and times parsed from input. The value should be either a
  # <tt>TZInfo::Timezone</tt> instance or a string that refers to a time zone
  # when passed to <tt>TZInfo::Timezone#get</tt>. If the value is +nil+, then
  # parsing will be assumed in UTC.
  def time_zone=(value)
    if value
      @local_time_builder = TZTime::LocalTime::Builder.new(value)
    else
      reset_local_time_builder!
    end
  end
  
  alias time_zone_name= time_zone=
  
  # Resets the +local_time_builder+ to the default which is UTC.
  def reset_local_time_builder!
    @local_time_builder = TZTime::LocalTime::Builder.utc
  end
  
  # Selects a TZTime::LocalTime::Builder instance giving precedence to the
  # +options+. If +options+ contains a <tt>:local_time_builder</tt> value, that
  # will be returned. If +options+ contains a <tt>:time_zone</tt> value, then a
  # builder will be instantiated for that time zone. Otherwise, the currentnly
  # set +local_time_builder+ will be returned.
  def select_local_time_builder(options={})
    options[:local_time_builder] ||
      (options[:time_zone] && TZTime::LocalTime::Builder.new(options[:time_zone])) ||
      local_time_builder
  end
end
