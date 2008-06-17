module Lucifer
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def encrypt_attributes
      return if self.included_modules.include? Lucifer::InstanceMethods
      __send__ :include, Lucifer::InstanceMethods
      
      cattr_accessor :encrypted_columns, :decrypted_columns
      
      self.encrypted_columns = columns.select{|col| col.type == :binary && col.name =~ /_b$/}.collect(&:name)  
      self.decrypted_columns = encrypted_columns.collect{|col| col.chomp '_b' }
      decrypted_columns.each { |col| attr_accessor col }
      
      before_save :encrypt_columns
      
      class_eval do 
        # Have to call it like this for performance reasons
        # http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html
        def after_initialize
          decrypt_columns
        end
      end
    end
    
    def encrypt(value)
      value
    end
    
    def decrypt(value)
      value
    end
  end
  
  
  
  module InstanceMethods
    
    def encrypt_columns
      self.class.decrypted_columns.each do |col|
        __send__ "#{col}_b=", self.class.encrypt(col)
      end
    end
    
    def decrypt_columns
      self.class.encrypted_columns.each do |col|
        __send__ "#{col.chomp '_b'}=", self.class.decrypt(col)
      end
    end
    
  end
  
end