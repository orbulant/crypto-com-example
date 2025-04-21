class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :wallet, null: false, foreign_key: true, type: :uuid
      t.decimal :amount

      t.timestamps
    end
  end
end
