module TZTime::ActiveRecord::Acts # :nodoc:
  module LocalTime # :nodoc:
    
    def self.included(into)
      into.extend ClassMethods
    end
    
    # This acts provides the capabilities for storing time zones and using them
    # to generate and convert times. This requires that ActiveRecord be
    # configured to store times in utc. Requiring tztime/activerecord will
    # configure ActiveRecord itself.
    #
    # This will add a composed_of property using the name provided by the
    # <tt>:time_builder_accessor</tt> (defaults to <tt>:local_time_builder</tt>)
    # and gets the time zone name from the <tt>:time_zone_field</tt> option
    # (defaults to <tt>:time_zone</tt>).
    #
    # All methods that return a Time or DateTime object gain the ability to be
    # localized to the timezone used by the model instance. For example, a
    # <tt>created_at</tt> field value can be localized via <tt>local_created_at</tt>.
    # This is not limited to field accessors; custom methods also gain this
    # capability. For example:
    # 	class Foo < ActiveRecord::Base
    # 	  acts_as_time_zone
    #
    # 	  def bar
    # 	    Time.now # will be in UTC
    # 	  end
    # 	end
    #
    # A localized value of <tt>bar</tt> can be accessed via <tt>local_bar</tt>.
    # This value will be converted into a TZTime::LocalTime instance with the
    # time zone set in the Foo instance.
    #
    # ==== Parameters
    # options<Hash>:: See below.
    #
    # ==== Options
    # :time_zone_field<Symbol,String>::
    #   The field in the database that holds the time zone name.
    #   Default <tt>:time_zone</tt>
    #
    # :time_builder_accessor<Symbol,String>::
    #   The name of the +composed_of+ field to create to access the local time
    #   builder instance.
    #   Default <tt>:local_time_builder</tt>
    #
    # === Usage
    # Create a migration that includes a +time_zone+ field :
    #   class CreateSettings < ActiveRecordMigration
    #     def self.up
    #       create_table :settings do |t|
    #         t.string :time_zone
    #         t.timestamps
    #       end
    #     end
    #   end
    #
    # Define the Setting model:
    #   require 'tztime/activerecord'
    #
    #   class Setting < ActiveRecord::Base
    #     acts_as_time_zone
    #   end
    #
    # Create an instance and get the current date and time
    #   setting = Setting.create :time_zone => 'Eastern Time (US & Canada)'
    #   setting.time_zone_builder.now
    #   setting.created_at # => time in UTC
    #   setting.local_created_at # => time in EDT or EST
    module ClassMethods
      def acts_as_local_time(options={})
        options = {
          :time_zone_field => :time_zone,
          :time_builder_accessor => :local_time_builder
        }.merge(options)
        
        write_inheritable_attribute(:acts_as_local_time_options, options)
        class_inheritable_reader :acts_as_local_time_options
        
        if options[:time_builder_accessor] && options[:time_zone_field]
          composed_of(options[:time_builder_accessor].to_sym, {
	    :class_name => 'TZTime::LocalTime::Builder',
	    :mapping => %W{#{options[:time_zone_field]} time_zone_name}
	  })
        end

	include InstanceMethods
      end
    end

    module InstanceMethods # :nodoc:
      def self.included(into)
	into.alias_method_chain :method_missing, :local_time
      end

      def method_missing_with_local_time(name, *args, &block)
	ns = name.to_s
	if ns =~ /local_(.+)/ && 
	  value = send!($1, *args, &block)
	  if value.is_a?(Time) || value.is_a?(DateTime)
	    builder = send!(acts_as_local_time_options[:time_builder_accessor])
	    return builder.at_utc(value)
	  end
	end
	method_missing_without_local_time(name, *args, &block)
      end
    end
  end
end
