# An instance of LocalTime::Builder is used to generate LocalTime instances
# based on the +time_zone+ of the Builder. The LocalTime instances wrap
# a Time instance that has properties reflective of +time_zone+. The Time
# values themselves are represented internally as UTC, but the time has
# been offset by the +time_zone+. This is due to a limitation of the Time
# class in Ruby.
#
# The Builder is created by passing in either a String that names a time
# zone, or a TZInfo time zone definition. The String name can be either
# the format used by TZInfo or Rails.
#
# === Usage
# Create a new Builder for the time zone in New York.
# 
#   builder = TZTime::LocalTime::Builder.new('America/New_York')
#   puts builder.time_zone_name  # => America/New_York
# 
# Underneath, this will have the same TZInfo time zone definition as above.
# 
#   builder = TZTime::LocalTime::Builder.new('Eastern Time (US & Canada)')
#   puts builder.time_zone_name  # => Eastern Time (US & Canada)
# 
# +now+ will create the current day and time, while +today+ will create the
# current day with time at 0:00. Both of these will be converted to the
# +time_zone+ of the Builder instance.
# 
#   puts builder.now    # => 2007-12-12 22:28:09 EST
#   puts builder.today  # => 2007-12-12 00:00:00 EST
# 
# The Builder can also create LocalTime instances at specific times using
# +local+ and +utc+. +local+ assumes the values passed in are expressed
# in the +time_zone+, while +utc+ assumes the values are in Univeral Time
# and need to be converted into the +time_zone+ time.
# 
#   puts builder.utc(2007, 12, 13, 3, 36, 26)     # => 2007-12-12 22:36:26 EST
#   puts builder.local(2007, 12, 13, 3, 36, 26)   # => 2007-12-13 03:36:26 EST
#   puts builder.local(2007, 12, 12, 22, 36, 26)  # => 2007-12-12 22:36:26 EST
# 
# Using, +at_local+ and +at_utc+, the Builder can convert existing time
# values into localized values. +at_local+ assumes time values represent
# the current +time_zone+, ignoring the time zone of the value. +at_utc+
# assumes the time values represent Universal Time values while still
# ignoring the time zone of the value.
# 
#   time = Time.utc(2007, 12, 13, 3, 36, 26)
#   puts builder.at_utc(time)    # => 2007-12-12 22:36:26 EST
#   puts builder.at_local(time)  # => 2007-12-13 03:36:26 EST
#
#   time = Time.local(2007, 12, 13, 3, 36, 26)
#   puts builder.at_utc(time)    # => 2007-12-12 22:36:26 EST
#   puts builder.at_local(time)  # => 2007-12-13 03:36:26 EST
# 
# +at+ is aliased to +at_local+, so it can be used instead.
#
# Converting from a seperate time zone into the builder's time zone can be done
# with the +convert+ method. This will convert from the time zone of the time
# value. Optionally, an explicit time zone can be specified:
#
#   builder = TZTime::LocalTime::Builder.new('America/Los_Angeles')
#   time = Time.now
#   # time zone is EDT
#   puts time # => Thu Apr 10 18:42:40 -0400 2008
#   puts builder.convert(time) # => 2008-04-10 15:42:40 PDT
#   puts builder.convert(time, 'America/Chicago') # => 2008-04-10 16:42:40 PDT
class TZTime::LocalTime::Builder
  # Uses +get+ to acquire a Builder instance in the UTC time zone.
  def self.utc
    new('UTC')
  end

  # Gets a time zone instance for a given +name+. The +name+ can be either the
  # names used by TZInfo or the TimeZone class in ActiveSupport.
  def self.get_time_zone(name)
    TZInfo::Timezone.get(RAILS_CONVERSIONS[name] || name)
  end

  # Creates a new LocalTime::Builder that can create LocalTime instances
  # relative to the given time zone.
  #
  # The +time_zone+ must be either a String that names a time zone, or an
  # instance of a TZInfo time zone definition. The String name can be either
  # the format used by TZInfo or Rails.
  #
  # If a String name is passed in, this value will be retained and accessible
  # by +time_zone_name+. If a TZInfo time zone definition value is passed,
  # then +time_zone_name+ will return the +name+ attribute of the TZInfo time
  # zone definition.
  def initialize(time_zone)
    if time_zone.is_a?(String)
      @time_zone = self.class.get_time_zone(time_zone)
      @time_zone_name = time_zone
    else
      @time_zone = time_zone
      @time_zone_name = time_zone.name
    end
    freeze
  end
  
  # The name of the time zone. This will reflect the name that was passed to
  # +new+. If a rails-style time zone name was used, this will return that
  # value. Otherwise it will return the +name+ attribute from the TZInfo time
  # zone definition.
  def time_zone_name
    @time_zone_name
  end
  
  # The TZInfo time zone instance
  def time_zone
    @time_zone
  end

  # Create a new LocalTime object representing the current day and time
  # in the given +time_zone+.
  def now
    create(@time_zone.utc_to_local(Time.now.utc))
  end
  
  # Create a new LocalTime object representing the current day in the
  # given +time_zone+.
  def today
    time = @time_zone.utc_to_local(Time.now.utc)
    create(Time.utc(time.year, time.month, time.day))
  end

  # call-seq:
  #   today_at_local(hour [, min, sec, usec]) => LocalTime
  #   today_at(hour [, min, sec, usec]) => LocalTime
  #
  # Create a new LocalTime object representing the current day and the
  # specified time. The time values are assumed to be in local +time_zone+.
  def today_at_local(*args)
    day_at_local(today, *args)
  end
  
  alias today_at today_at_local # :nodoc:
  
  # call-seq:
  #   today_at_utc(hour [, min, sec, usec]) => LocalTime
  #   today_at_gm(hour [, min, sec, usec]) => LocalTime
  #
  # Create a new LocalTime object representing the current day and the
  # specified time. The time values are assumed to be in Universal Time and
  # will be converted to the +time_zone+.
  def today_at_utc(*args)
    day_at_utc(today, *args)
  end

  alias today_at_gm today_at_utc # :nodoc:
  
  # call-seq:
  #   day_at_local(time  [, min, sec, usec]) => LocalTime
  #   day_at(time  [, min, sec, usec]) => LocalTime
  #
  # Create a new LocalTime object representing the day in +time+ and the
  # specified time. The time values are assumed to be in local +time_zone+.
  def day_at_local(time, *args)
    local(time.year, time.month, time.day, *args)
  end
  
  alias day_at day_at_local # :nodoc:
  
  # call-seq:
  #   day_at_utc(time  [, min, sec, usec]) => LocalTime
  #   day_at_gm(time  [, min, sec, usec]) => LocalTime
  #
  # Create a new LocalTime object representing the day in +time+ and the
  # specified time. The time values are assumed to be in Universal Time and
  # will be converted to the +time_zone+.
  def day_at_utc(time, *args)
    utc(time.year, time.month, time.day, *args)
  end
  
  alias day_at_gm day_at_utc

  # call-seq:
  #   local(year [, month, day, hour, min, sec, usec]) => LocalTime
  #   local(sec, min, hour, day, month, year, wday, yday, isdst, tz) => LocalTime
  #
  # Create a LocalTime where the arguments are expressed locally to the +time_zone+.
  def local(*args)
    create(Time.utc(*args))
  end

  # call-seq:
  #   utc(year [, month, day, hour, min, sec, usec]) => LocalTime
  #   utc(sec, min, hour, day, month, year, wday, yday, isdst, tz) => LocalTime
  #   gm(year [, month, day, hour, min, sec, usec]) => LocalTime
  #   gm(sec, min, hour, day, month, year, wday, yday, isdst, tz) => LocalTime
  #
  # Create a LocalTime where the arguments are expressed in UTC. This will convert
  # the time value into the local +time_zone+.
  def utc(*args)
    create(@time_zone.utc_to_local(Time.utc(*args)))
  end
  
  alias gm utc # :nodoc:
  
  # call-seq:
  #   at_local(time) => LocalTime
  #   at_local(second [, microseconds]) => LocalTime
  #   at(time) => LocalTime
  #   at(second [, microseconds]) => LocalTime
  #
  # Takes a Time instance and returns a LocalTime instance. The time is read
  # as if in the timezone of this Builder instance, regardless of the time
  # zone value. However, if a LocalTime instance is passed in, the proper
  # conversion will take place.
  def at_local(*args)
    extract_and_create_local_time(args, true)
  end

  alias at at_local # :nodoc:
  
  # call-seq:
  #   at_utc(time) => LocalTime
  #   at_utc(second [, microseconds]) => LocalTime
  #   at_gm(time) => LocalTime
  #   at_gm(second [, microseconds]) => LocalTime
  #      
  # Takes a Time instance and returns a LocalTime instance. The time is read
  # as if in universal time and converted to the, regardless of the time zone
  # value. However, if a LocalTime instance is passed in, the proper conversion
  # will take place.
  def at_utc(*args)
    extract_and_create_local_time(args, false)
  end
  
  alias at_gm  at_utc# :nodoc:
  
  # Creates a new LocalTime instance converted from +local_time+'s time zone
  # into this time zone. If +local_time+ is in the same time zone, then
  # +local_time+ will be returned. If +local_time+ is not an instance of
  # LocalTime, then +from_time_zone+ must be passed in. +from_time_zone+ will be ignored
  # if +local_time+ is an instance of LocalTime.
  def convert(local_time, from_time_zone=nil)
    if from_time_zone
      b = self.class.new(from_time_zone)
      t = b.at(local_time).getutc
      utc(t.year, t.month, t.day, t.hour, t.min, t.sec, t.usec)
    elsif local_time.respond_to?(:getutc)
      t = local_time.getutc
      utc(t.year, t.month, t.day, t.hour, t.min, t.sec, t.usec)
    else
      nil
    end
  end
  
  protected

    def extract_and_create_local_time(time_args, local=true)
      time = extract_time_from_args(time_args)
      if time.is_a?(TZTime::LocalTime)
	convert(time)
      elsif local
	local(time.year, time.month, time.day, time.hour, time.min, time.sec, time.usec)
      else
	utc(time.year, time.month, time.day, time.hour, time.min, time.sec, time.usec)
      end
    end

    # Creates a LocalTime object from +time+ and the given +time_zone+.
    # The time value does not get modified. In other words, it is assumed
    # to be in the +time_zone+.
    def create(time)
      TZTime::LocalTime.new(time, @time_zone)
    end
  
    # Converts +args+ into a Time object.
    def extract_time_from_args(args)
      time = args.first
      case time
      when TZTime::LocalTime then args.first
      when Time then args.first
      when DateTime then Time.utc(time.year, time.month, time.day, time.hour, time.min, time.sec, 0)
      when Date then Time.utc(time.year, time.month, time.day, 0, 0, 0, 0)
      else Time.at(*args)
      end
    end

  RAILS_CONVERSIONS = {
    "International Date Line West" => "Pacific/Midway",
    "Midway Island"                => "Pacific/Midway",
    "Samoa"                        => "Pacific/Pago_Pago",
    "Hawaii"                       => "Pacific/Honolulu",
    "Alaska"                       => "America/Juneau",
    "Pacific Time (US & Canada)"   => "America/Los_Angeles",
    "Tijuana"                      => "America/Tijuana",
    "Mountain Time (US & Canada)"  => "America/Denver",
    "Arizona"                      => "America/Phoenix",
    "Chihuahua"                    => "America/Chihuahua",
    "Mazatlan"                     => "America/Mazatlan",
    "Central Time (US & Canada)"   => "America/Chicago",
    "Saskatchewan"                 => "America/Regina",
    "Guadalajara"                  => "America/Mexico_City",
    "Mexico City"                  => "America/Mexico_City",
    "Monterrey"                    => "America/Monterrey",
    "Central America"              => "America/Guatemala",
    "Eastern Time (US & Canada)"   => "America/New_York",
    "Indiana (East)"               => "America/Indiana/Indianapolis",
    "Bogota"                       => "America/Bogota",
    "Lima"                         => "America/Lima",
    "Quito"                        => "America/Lima",
    "Atlantic Time (Canada)"       => "America/Halifax",
    "Caracas"                      => "America/Caracas",
    "La Paz"                       => "America/La_Paz",
    "Santiago"                     => "America/Santiago",
    "Newfoundland"                 => "America/St_Johns",
    "Brasilia"                     => "America/Argentina/Buenos_Aires",
    "Buenos Aires"                 => "America/Argentina/Buenos_Aires",
    "Georgetown"                   => "America/Argentina/San_Juan",
    "Greenland"                    => "America/Godthab",
    "Mid-Atlantic"                 => "Atlantic/South_Georgia",
    "Azores"                       => "Atlantic/Azores",
    "Cape Verde Is."               => "Atlantic/Cape_Verde",
    "Dublin"                       => "Europe/Dublin",
    "Edinburgh"                    => "Europe/Dublin",
    "Lisbon"                       => "Europe/Lisbon",
    "London"                       => "Europe/London",
    "Casablanca"                   => "Africa/Casablanca",
    "Monrovia"                     => "Africa/Monrovia",
    "Belgrade"                     => "Europe/Belgrade",
    "Bratislava"                   => "Europe/Bratislava",
    "Budapest"                     => "Europe/Budapest",
    "Ljubljana"                    => "Europe/Ljubljana",
    "Prague"                       => "Europe/Prague",
    "Sarajevo"                     => "Europe/Sarajevo",
    "Skopje"                       => "Europe/Skopje",
    "Warsaw"                       => "Europe/Warsaw",
    "Zagreb"                       => "Europe/Zagreb",
    "Brussels"                     => "Europe/Brussels",
    "Copenhagen"                   => "Europe/Copenhagen",
    "Madrid"                       => "Europe/Madrid",
    "Paris"                        => "Europe/Paris",
    "Amsterdam"                    => "Europe/Amsterdam",
    "Berlin"                       => "Europe/Berlin",
    "Bern"                         => "Europe/Berlin",
    "Rome"                         => "Europe/Rome",
    "Stockholm"                    => "Europe/Stockholm",
    "Vienna"                       => "Europe/Vienna",
    "West Central Africa"          => "Africa/Algiers",
    "Bucharest"                    => "Europe/Bucharest",
    "Cairo"                        => "Africa/Cairo",
    "Helsinki"                     => "Europe/Helsinki",
    "Kyev"                         => "Europe/Kiev",
    "Riga"                         => "Europe/Riga",
    "Sofia"                        => "Europe/Sofia",
    "Tallinn"                      => "Europe/Tallinn",
    "Vilnius"                      => "Europe/Vilnius",
    "Athens"                       => "Europe/Athens",
    "Istanbul"                     => "Europe/Istanbul",
    "Minsk"                        => "Europe/Minsk",
    "Jerusalem"                    => "Asia/Jerusalem",
    "Harare"                       => "Africa/Harare",
    "Pretoria"                     => "Africa/Johannesburg",
    "Moscow"                       => "Europe/Moscow",
    "St. Petersburg"               => "Europe/Moscow",
    "Volgograd"                    => "Europe/Moscow",
    "Kuwait"                       => "Asia/Kuwait",
    "Riyadh"                       => "Asia/Riyadh",
    "Nairobi"                      => "Africa/Nairobi",
    "Baghdad"                      => "Asia/Baghdad",
    "Tehran"                       => "Asia/Tehran",
    "Abu Dhabi"                    => "Asia/Muscat",
    "Muscat"                       => "Asia/Muscat",
    "Baku"                         => "Asia/Baku",
    "Tbilisi"                      => "Asia/Tbilisi",
    "Yerevan"                      => "Asia/Yerevan",
    "Kabul"                        => "Asia/Kabul",
    "Ekaterinburg"                 => "Asia/Yekaterinburg",
    "Islamabad"                    => "Asia/Karachi",
    "Karachi"                      => "Asia/Karachi",
    "Tashkent"                     => "Asia/Tashkent",
    "Chennai"                      => "Asia/Calcutta",
    "Kolkata"                      => "Asia/Calcutta",
    "Mumbai"                       => "Asia/Calcutta",
    "New Delhi"                    => "Asia/Calcutta",
    "Kathmandu"                    => "Asia/Katmandu",
    "Astana"                       => "Asia/Dhaka",
    "Dhaka"                        => "Asia/Dhaka",
    "Sri Jayawardenepura"          => "Asia/Dhaka",
    "Almaty"                       => "Asia/Almaty",
    "Novosibirsk"                  => "Asia/Novosibirsk",
    "Rangoon"                      => "Asia/Rangoon",
    "Bangkok"                      => "Asia/Bangkok",
    "Hanoi"                        => "Asia/Bangkok",
    "Jakarta"                      => "Asia/Jakarta",
    "Krasnoyarsk"                  => "Asia/Krasnoyarsk",
    "Beijing"                      => "Asia/Shanghai",
    "Chongqing"                    => "Asia/Chongqing",
    "Hong Kong"                    => "Asia/Hong_Kong",
    "Urumqi"                       => "Asia/Urumqi",
    "Kuala Lumpur"                 => "Asia/Kuala_Lumpur",
    "Singapore"                    => "Asia/Singapore",
    "Taipei"                       => "Asia/Taipei",
    "Perth"                        => "Australia/Perth",
    "Irkutsk"                      => "Asia/Irkutsk",
    "Ulaan Bataar"                 => "Asia/Ulaanbaatar",
    "Seoul"                        => "Asia/Seoul",
    "Osaka"                        => "Asia/Tokyo",
    "Sapporo"                      => "Asia/Tokyo",
    "Tokyo"                        => "Asia/Tokyo",
    "Yakutsk"                      => "Asia/Yakutsk",
    "Darwin"                       => "Australia/Darwin",
    "Adelaide"                     => "Australia/Adelaide",
    "Canberra"                     => "Australia/Melbourne",
    "Melbourne"                    => "Australia/Melbourne",
    "Sydney"                       => "Australia/Sydney",
    "Brisbane"                     => "Australia/Brisbane",
    "Hobart"                       => "Australia/Hobart",
    "Vladivostok"                  => "Asia/Vladivostok",
    "Guam"                         => "Pacific/Guam",
    "Port Moresby"                 => "Pacific/Port_Moresby",
    "Magadan"                      => "Asia/Magadan",
    "Solomon Is."                  => "Asia/Magadan",
    "New Caledonia"                => "Pacific/Noumea",
    "Fiji"                         => "Pacific/Fiji",
    "Kamchatka"                    => "Asia/Kamchatka",
    "Marshall Is."                 => "Pacific/Majuro",
    "Auckland"                     => "Pacific/Auckland",
    "Wellington"                   => "Pacific/Auckland",
    "Nuku'alofa"                   => "Pacific/Tongatapu"
  }
end

