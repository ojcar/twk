# ActsAsVoteable
module Juixe
  module Acts #:nodoc:
    module Voteable #:nodoc:

      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_voteable
          has_many :votes, :as => :voteable, :dependent => :destroy
          include Juixe::Acts::Voteable::InstanceMethods
          extend Juixe::Acts::Voteable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        def find_votes_cast_by_user(user)
          voteable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          Vote.find(:all,
            :conditions => ["user_id = ? and voteable_type = ?", user.id, voteable],
            :order => "created_at DESC"
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        def votes_for
          votes = Vote.find(:all, :conditions => [
            "voteable_id = ? AND voteable_type = 'Snippet' AND vote = TRUE",
            id # , self.type.name
          ])
          votes.size
        end
        
        def votes_against
          votes = Vote.find(:all, :conditions => [
            "voteable_id = ? AND voteable_type = 'Snippet' AND vote = FALSE",
            id # , self.type.name
          ])
          votes.size
        end
        
        # Same as voteable.votes.size
        def votes_count
          self.votes.size
        end
        
        def users_who_voted
          users = []
          self.votes.each { |v|
            users << v.user
          }
          users
        end
        
        def voted_yes_by_user?(voter,user)
          votes = Vote.find(:first, :conditions => ["user_id = ? AND voteable_id = ? ", user.id, voter])
          # votes = Vote.find(:first, :conditions => ["user_id = 3 AND voteable_id = 10 "])
          if votes.vote == 1
            rtn = true
          else
            rtn = false
          end
          rtn
        end
        
        def voted_by_user?(user)
          rtn = false
          if user
            self.votes.each { |v|
              rtn = true if user.id == v.user_id
            }
          end
          rtn
        end
        
      end
    end
  end
end