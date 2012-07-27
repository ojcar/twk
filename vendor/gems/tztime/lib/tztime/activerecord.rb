require 'tztime'

ENV['TZ'] ||= 'UTC'
require 'activerecord' unless defined? ActiveRecord

# Adds the capability to store and use time zones in ActiveRecord models.
#
# See TZTime::ActiveRecord::Acts::LocalTime::ClassMethods
module TZTime::ActiveRecord
  require 'tztime/activerecord/acts/local_time'
end

ActiveRecord::Base.send :include, TZTime::ActiveRecord::Acts::LocalTime
ActiveRecord::Base.default_timezone = :utc
