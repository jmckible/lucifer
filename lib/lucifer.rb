module Lucifer
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def encrypt_attributes
      cattr_accessor :encrypted_columns
      self.encrypted_columns = columns.select{|col| col.type == :binary && col.name =~ /_b$/}.collect(&:name)  
      encrypted_columns.each { |col| attr_accessor col.chomp('_b') }
      
    end
  end
  
end