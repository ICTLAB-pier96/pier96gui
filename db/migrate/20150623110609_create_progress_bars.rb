class CreateProgressBars < ActiveRecord::Migration
  def change
    drop_table(:progress_bars, if_exists: true)
    create_table :progress_bars do |t|
      t.float :max
      t.float :current
      t.float :percentage
      t.timestamp :start_time
      t.timestamp :previous_time

      t.timestamps null: false
    end
  end
end
