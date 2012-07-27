require 'time'
require 'rubygems'
require 'tzinfo'

# A LocalTime instance wraps a Time value and a TZInfo time zone definition.
# The LocalTime class acts as a proxy to the Time value, enabling instances
# of this class to walk and talk like the Time duck.
# 
# Certain methods are implemented directly in order to behave as expected
# +strftime+, +httpdate+, +rfc2822+, and +xmlschema+ are implemented to take
# proper conversions and/or time zone abbreviations into account. +getutc+
# has been implemented to create a time value converted to UTC and returned.
# (instead of returning a LocalTime instance). +to_time+, +to_date+, and
# +to_datetime+ will convert the time and return Time, Date, and DateTime
# values, respectively, converted into Universal Time. The behavior of
# +to_date+ and +to_datetime+ can be modified to not convert to UTC.
class TZTime::LocalTime
  include Comparable

  # The Time value wrapped by this instance.
  attr_reader :time
  
  # The TZInfo time zone definition that represents the time zone of the value
  attr_reader :time_zone
  
  # Creates a new LocalTime instance that wraps the value of +time+. +time+
  # must be an instance of Time, and +time_zone must be an instance of 
  # TZInfo::Timezone. In most circumstances, these should not be created
  # directly. Typically they will be created by a TZTime::LocalTime::Builder
  # instance.
  #
  # ==== Parameters
  # time<Time>::
  #   The date and time in the desired time zone. The time zone of the instance
  #   is ignored.
  # time_zone<TZInfo::Timezone>::
  #   The time zone of the instance.
  def initialize(time, time_zone)
    raise ArgumentError, "The 'time' parameter must be an instance of Time" unless time.is_a?(Time)
    raise ArgumentError, "The 'time_zone' parameter must be an instance of TZInfo::Timezone" unless time_zone.is_a?(TZInfo::Timezone)
    @time = time
    @time_zone = time_zone
  end
  
  # call-seq:
  #   time + numeric => time
  #
  # Addition. Adds some number of seconds (possibly fractional) to time and
  # returns that value as a new time.
  #
  #   builder = TZTime::LocalTime::Builder.new('America/New_York')
  #   t = builder.local(2007, 12, 16, 10, 30) # => 2007-12-16 10:30:00 EST
  #   t + (60 * 60 * 24)                      # => 2007-12-17 10:30:00 EST
  def +(value)
    self.class.new(@time + (value.is_a?(self.class) ? value.time : value), @time_zone)
  end
  
  # call-seq:
  #   time - other_time => float
  #   time - numeric => time
  #
  # Difference. Returns a new time that represents the difference between two
  # times, or subtracts the given number of seconds in numeric from time.
  #
  #   builder = TZTime::LocalTime::Builder.new('America/New_York')
  #   t = builder.local(2007, 12, 16, 10, 30)  # => 2007-12-16 10:30:00 EST
  #   t2 = builder.local(2007, 12, 17, 10, 30) # => 2007-12-17 10:30:00 EST
  #   t2 - (60 * 60 * 24)                      # => 2007-12-16 10:30:00 EST
  #   t2 - t                                   # => 86400
  def -(value)
    t = @time - (value.is_a?(self.class) ? value.time : value)
    t.is_a?(Numeric) ? t : self.class.new(t, @time_zone)
  end
  
  # The full name of the time zone. This is the name used by TZInfo time zone definition
  def time_zone_name
    time_zone.name
  end
  
  # The +time_zone_abbreviation+ as a string
  def zone
    time_zone_abbreviation.to_s
  end
  
  # The offset from Universal Time in seconds
  def time_zone_offset
    time_zone_period.utc_total_offset
  end
  
  alias utc_offset time_zone_offset
  alias gm_offset time_zone_offset
  
  # The time zone offset as a fraction of a day (as a Rational).
  def time_zone_offset_fraction
    Rational(time_zone_offset, 86_400)
  end

  alias offset_fraction time_zone_offset_fraction
  
  # Get the abbreviated time zone name as a Symbol. (ex :EDT, :UTC)
  def time_zone_abbreviation
    time_zone_period.abbreviation
  end
  
  alias time_zone_identifier time_zone_abbreviation
  
  # Get a Time instance converted to UTC from the local time.
  def getutc
    @getutc ||= time_zone_period.to_utc(@time)
  end
  
  alias utc getutc
  alias getgm getutc
  alias to_time getutc

  def getlocal
    dup
  end
  
  # Convert this to a Date instance in the Universal Time. If +utc+ is
  # +false+, then the value will not be converted to Universal Time first.
  # Note, this can create a misleading value because Date instance cannot
  # store a time zone offset.
  def to_date(utc=true)
    t = utc ? getutc : @time
    Date.civil(t.year, t.month, t.day)
  end
  
  # Convert this to a DateTime instance in the Univeral Time. If +utc+ is
  # +false+, then a DateTime with the proper time zone offset will be created.
  def to_datetime(utc=true)
    t = utc ? getutc : @time
    DateTime.civil(t.year, t.month, t.day, t.hour, t.min, t.sec, utc ? 0 : time_zone_offset_fraction)
  end
  
  # Returns the +hour+, +min+, and +sec+ as seconds. The seconds are offset by
  # the +time_zone_offset+, which can adjust the value below 0 or above 86400
  # (one day).
  def utc_day_seconds
    local_day_seconds - time_zone_offset
  end
  
  alias gm_day_seconds gm_day_seconds
  
  # Returns the +hour+, +min+, and +sec+ as seconds.
  def local_day_seconds
    @time.sec + (@time.min * 60) + (@time.hour * 3600)
  end
  
  alias day_seconds local_day_seconds

  # Compare this instance's value of +time+ with another LocalTime or Time value.
  def <=>(value)
    getutc <=> value.getutc
  end

  # Determine if the time zone is in Universal Time.
  def utc?
    time_zone_period.abbreviation == :UTC
  end

  # Find the <tt>TZInfo::TimezonePeriod<?tt> for the +time_zone+
  def time_zone_period
    return @time_zone_period if defined?(@time_zone_period)
    @time_zone_period = @time_zone.period_for_local(@time, @time.dst?)
  end

  # Determine if the current time is during Daylight Savings Time.
  def dst?
    time_zone_period.dst?
  end
  
  # Formats the time according to the directives in the given format string.
  # Any text not listed as a directive will be passed through to the output string.
  # 
  # Format meaning:
  # 
  #   %a - The abbreviated weekday name ('Sun')
  #   %A - The  full  weekday  name ('Sunday')
  #   %b - The abbreviated month name ('Jan')
  #   %B - The  full  month  name ('January')
  #   %c - The preferred local date and time representation
  #   %d - Day of the month (01..31)
  #   %H - Hour of the day, 24-hour clock (00..23)
  #   %I - Hour of the day, 12-hour clock (01..12)
  #   %j - Day of the year (001..366)
  #   %m - Month of the year (01..12)
  #   %M - Minute of the hour (00..59)
  #   %p - Meridian indicator ('AM' or 'PM')
  #   %P - Meridian indicator ('a' or 'p')
  #   %S - Second of the minute (00..60)
  #   %U - Week  number  of the current year,
  #           starting with the first Sunday as the first
  #           day of the first week (00..53)
  #   %W - Week  number  of the current year,
  #           starting with the first Monday as the first
  #           day of the first week (00..53)
  #   %w - Day of the week (Sunday is 0, 0..6)
  #   %x - Preferred representation for the date alone, no time
  #   %X - Preferred representation for the time alone, no date
  #   %y - Year without a century (00..99)
  #   %Y - Year with century
  #   %Z - Time zone name
  #   %% - Literal '%' character
  # 
  #    t = Time.now
  #    t.strftime("Printed on %m/%d/%Y")   #=> "Printed on 04/09/2003"
  #    t.strftime("at %I:%M%p")            #=> "at 08:56AM"
  def strftime(string)
    @time.strftime(string.
		   gsub(/([^%]|\A)%Z/, "\\1#{zone}").
		   gsub(/([^%]|\A)%P/, "\\1#{@time.hour >= 12 ? 'p' : 'a'}"))
  end
  
  # Returns a string which represents the time as rfc1123-date of HTTP-date
  # defined by RFC 2616:
  #   day-of-week, DD month-name CCYY hh:mm:ss GMT
  # 
  # Note that the result is always UTC (GMT).
  def httpdate
    getutc.httpdate
  end

  alias rfc1123 httpdate
  
  # Returns a string which represents the time as date-time defined by RFC 2822:
  #   day-of-week, DD month-name CCYY hh:mm:ss zone
  # where zone is [+-]hhmm.
  # 
  # If +self+ is a UTC time, -0000 is used as zone.
  def rfc2822
    sprintf('%s, %02d %s %d %02d:%02d:%02d ',
      Time::RFC2822_DAY_NAME[@time.wday],
      @time.day, Time::RFC2822_MONTH_NAME[@time.mon-1], @time.year,
      @time.hour, @time.min, @time.sec) +
    if utc?
      '-0000'
    else
      off = utc_offset
      sign = off < 0 ? '-' : '+'
      sprintf('%s%02d%02d', sign, *(off.abs / 60).divmod(60))
    end
  end

  alias rfc822 rfc2822

  # Returns a string which represents the time as dateTime defined by XML Schema:
  #   CCYY-MM-DDThh:mm:ssTZD
  #   CCYY-MM-DDThh:mm:ss.sssTZD
  # where TZD is Z or [+-]hh:mm.
  #
  # If self is a UTC time, Z is used as TZD. [+-]hh:mm is used otherwise.
  # 
  # +fraction_digits+ specifies a number of digits of fractional seconds. Its
  # default value is 0.
  def xmlschema(fraction_digits=0)
    sprintf('%d-%02d-%02dT%02d:%02d:%02d',
      @time.year, @time.mon, @time.day, @time.hour, @time.min, @time.sec) +
    if fraction_digits.nil? || fraction_digits == 0
      ''
    elsif fraction_digits <= 6
      '.' + sprintf('%06d', @time.usec)[0, fraction_digits]
    else
      '.' + sprintf('%06d', @time.usec) + '0' * (fraction_digits - 6)
    end +
    if utc?
      'Z'
    else
      off = utc_offset
      sign = off < 0 ? '-' : '+'
      sprintf('%s%02d:%02d', sign, *(off.abs / 60).divmod(60))
    end
  end

  alias iso8601 xmlschema
  
  # Converts the time into an xml-compatible string. This is the same results
  # as using xmlschema, except that it can accept options. There are no options
  # for the method, it is accepted for campatibility with Rails.
  def to_xml(options=nil)
    xmlschema
  end
  
  def to_s #:nodoc:
    strftime("%Y-%m-%d %H:%M:%S %Z")
  end
  
  alias inspect to_s # :nodoc:

  def dup # :nodoc:
    self.class.new(@time.dup, @time_zone)
  end

  alias clone dup # :nodoc:

  # Also check if +@time+ can respond to a method because LocalTime acts as a
  # proxy to the underlying Time instance.
  def respond_to?(name) # :nodoc:
    super || @time.respond_to?(name)
  end

  # Pass on call to +@time+ unless it does not respond to the requested
  # method. If +@time+ does respond and the value returned is a new Time
  # value, that new value will be wrapped in a new LocalTime instance.
  def method_missing(name, *args, &block) #:nodoc:
    if @time.respond_to?(name)
      val = @time.send(name, *args, &block)
      val.is_a?(Time) ? self.class.new(val, @time_zone) : val
    else
      super
    end
  end
end
