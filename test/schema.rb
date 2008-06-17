ActiveRecord::Schema.define(:version=>0) do
  create_table :people, :force=>true do |t|
    t.binary :ssn_b
  end
end
