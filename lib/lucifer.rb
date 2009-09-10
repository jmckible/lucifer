module Lucifer
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def encrypt_attributes(options = {})
      return if self.included_modules.include? Lucifer::InstanceMethods
      __send__ :include, Lucifer::InstanceMethods
      
      cattr_accessor :encrypted_columns, :decrypted_columns, :key, :suffix, :key_file
      
      self.suffix   = options[:suffix]   || '_b'
      self.key_file = options[:key_file] || 'key.yml'
      
      self.encrypted_columns = columns.select{|col| col.type == :binary && col.name.ends_with?(suffix)}.collect(&:name)  
      self.decrypted_columns = encrypted_columns.collect{|col| col.chomp suffix }
      decrypted_columns.each { |col| attr_accessor col }
      
      before_save :encrypt_columns
      
      secret   = YAML.load_file("#{Rails.root}/config/#{key_file}")[Rails.env].symbolize_keys
      self.key = EzCrypto::Key.with_password secret[:key], secret[:salt]
    end
    
    def key_encrypt(value)
      key.encrypt value
    end
    
    def key_decrypt(value)
      key.decrypt value
    rescue # OpenSSL::CipherError # Specifying this class led to errors with Rails 2.3.4
      return nil
    end
  end
  
  
  module InstanceMethods
    def encrypt_columns
      self.class.decrypted_columns.each do |col|
        send "#{col}#{self.class.suffix}=", self.class.key_encrypt(eval(col))
      end
    end
    
    # Starting with Rails 2.3.3, this ActiveRecord exception was being raised
    # on certain associations related to a model with encrypt_attributes.
    # As a patch, only raise the exception if the method really doesn't exist
    # Warning: this method is designed to protect against uses of ActiveRecord#find
    # with the :select option, so be careful
    def missing_attribute(attr_name, stack)
      return nil if respond_to?(attr_name)
      raise ActiveRecord::MissingAttributeError, "missing attribute: #{attr_name}", stack
    end
    
    # Have to call it like this for performance reasons
    # http://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html
    def after_find
      decrypt_columns
    end
    
    def decrypt_columns
      self.class.encrypted_columns.each do |col|
        send "#{col.chomp self.class.suffix}=", self.class.key_decrypt(eval(col))
      end
    end
    
  end
  
end