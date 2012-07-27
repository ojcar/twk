require 'chronic'

class Prediction < ActiveRecord::Base
  has_many :snippets, :dependent => :nullify
  
  def before_save
    self.expiration = Chronic.parse(self.expiration_before_type_cast)
  end
  
  protected
  def validate
    errors.add :expiration, "is not a valid date. If it's a prediction we need an expiration date." if Chronic.parse(expiration_before_type_cast).nil?
  end
end
