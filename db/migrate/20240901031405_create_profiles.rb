class CreateProfiles < ActiveRecord::Migration[7.2]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :nickname
      t.string :gender
      t.date :birthday
      t.string :self_introduction
      t.string :self_introduction_url

      t.timestamps
    end
  end
end
