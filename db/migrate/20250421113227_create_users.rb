class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
