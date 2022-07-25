class CreateLexicalAnalyzers < ActiveRecord::Migration[7.0]
  def change
    create_table :lexical_analyzers do |t|
      t.text :progtext

      t.timestamps
    end
  end
end
