require 'chronic'

class Snippet < ActiveRecord::Base
  validates_presence_of :content
  validates_length_of :content, :maximum => 1000
  belongs_to :user
  belongs_to :category
  # belongs_to :prediction
  acts_as_voteable
  # acts_as_commentable

 #  def before_save
 #   self.expiration = Chronic.parse(self.expiration_before_type_cast)
 #  end
  
 # protected
 # def validate
  #  errors.add :expiration, "is not a valid date. If it's a prediction we need an expiration date." if Chronic.parse(expiration_before_type_cast).nil?
 # end
  
end
