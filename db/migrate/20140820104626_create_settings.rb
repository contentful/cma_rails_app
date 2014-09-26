class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :access_token
      t.string :organization_id
      t.string :space_id

      t.timestamps
    end
  end
end
