class CreateProjectApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :project_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
