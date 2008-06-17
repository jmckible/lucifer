module Lucifer
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def encrypt_attributes
    end
  end
  
end