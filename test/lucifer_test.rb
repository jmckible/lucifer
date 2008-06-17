require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'rubygems'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.configurations = {'test' => config[ENV['DB'] || 'sqlite3']}
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])

load(File.dirname(__FILE__) + '/schema.rb')

require File.join(File.dirname(__FILE__), 'person')

class LuciferTest < Test::Unit::TestCase

  def test_encrypt_proper_columns
    assert_equal ['ssn_b'], Person.encrypted_columns
  end
  
  def test_setup_virtual_attributes
    assert Person.new.respond_to?(:ssn)
    assert Person.new.respond_to?('ssn=')
  end
  
end