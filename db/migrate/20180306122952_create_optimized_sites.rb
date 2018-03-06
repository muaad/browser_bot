class CreateOptimizedSites < ActiveRecord::Migration[5.0]
  def change
    create_table :optimized_sites do |t|
      t.string :name
      t.string :root_url
      t.string :action
      t.boolean :enabled, default: false
      t.string :implementation, default: 'Internal'

      t.timestamps
    end
  end
end
