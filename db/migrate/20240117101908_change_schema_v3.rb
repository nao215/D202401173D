class ChangeSchemaV3 < ActiveRecord::Migration[6.0]
  def change
    change_table_comment :notes, from: 'Notes created by users', to: 'Stores notes created by users'
    change_table_comment :users, from: 'Registered users of the note application', to: 'Stores user account information'

    add_column :notes, :title, :string
  end
end
