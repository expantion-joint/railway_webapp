class CreatePosts < ActiveRecord::Migration[7.2]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.integer :category
      t.string :title
      t.string :body
      t.string :tag

      t.timestamps
    end
  end
end
