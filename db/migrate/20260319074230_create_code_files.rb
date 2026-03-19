class CreateCodeFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :code_files do |t|
      t.text :content
      t.string :language
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
