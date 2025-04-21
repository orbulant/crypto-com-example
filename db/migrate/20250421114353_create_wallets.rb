class CreateWallets < ActiveRecord::Migration[7.2]
  def change
    create_table :wallets, id: :uuid do |t|
      t.string :name
      t.decimal :balance
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
