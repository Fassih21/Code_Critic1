class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.string :status
      t.text :result
      t.text :summary
      t.references :code_file, null: false, foreign_key: true

      t.timestamps
    end
  end
end
