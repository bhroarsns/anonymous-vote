class CreateVotings < ActiveRecord::Migration[7.1]
  def change
    create_table :votings, id: :string do |t|
      t.string :title
      t.references :user, null: false, foreign_key: true
      t.text :description
      t.text :choices
      t.datetime :deadline
      t.string :mode
      t.text :config

      t.timestamps
    end
  end
end
