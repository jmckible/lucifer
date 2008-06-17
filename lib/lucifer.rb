module Lucifer
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def encrypt_attributes
      return if self.included_modules.include? Lucifer::InstanceMethods
      send :include, Lucifer::InstanceMethods
      
      cattr_accessor :encrypted_columns, :decrypted_columns, :key
      
      self.encrypted_columns = columns.select{|col| col.type == :binary && col.name =~ /_b$/}.collect(&:name)  
      self.decrypted_columns = encrypted_columns.collect{|col| col.chomp '_b' }
      decrypted_columns.each { |col| attr_accessor col }
      
      before_save :encrypt_columns
      
      secret   = YAML.load_file(Rails.root + '/config/key.yml')[Rails.env].symbolize_keys
      self.key = EzCrypto::Key.with_password secret[:key], secret[:salt]
    end
    
    def encrypt(value)
      key.encrypt value
    end
    
    def decrypt(value)
      key.decrypt value
    end
  end
  
  
  module InstanceMethods
    def encrypt_columns
      self.class.decrypted_columns.each do |col|
        send "#{col}_b=", self.class.encrypt(eval(col))
      end
    end
    
    # Have to call it like this for performance reasons
    # http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html
    def after_find
      decrypt_columns
    end
    
    def decrypt_columns
      self.class.encrypted_columns.each do |col|
        send "#{col.chomp '_b'}=", self.class.decrypt(eval(col))
      end
    end
    
  end
  
end