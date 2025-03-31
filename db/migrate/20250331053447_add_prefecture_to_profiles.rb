class AddPrefectureToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :prefecture, :string
  end
end
