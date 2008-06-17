ActiveRecord::Schema.define(:version=>0) do
  create_table :people, :force=>true do |t|
    t.string :name
    t.binary :ssn_b, :picture
  end
end
