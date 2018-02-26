class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :external_id
      t.string :channel

      t.timestamps
    end
  end
end
