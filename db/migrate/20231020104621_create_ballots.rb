class CreateBallots < ActiveRecord::Migration[7.1]
  def change
    create_table :ballots, id: :string do |t|
      t.references :voting, null: false, foreign_key: true, type: :string
      t.string :voter, null:false
      t.string :password_digest
      t.string :choice
      t.datetime :exp
      t.boolean :delivered
      t.boolean :delete_requested

      t.timestamps
    end
  end
end
