class Addschedulesconstraint < ActiveRecord::Migration[5.2]
  def change
    execute <<-SQL
      ALTER TABLE schedules ADD CONSTRAINT period_num CHECK (period_num > 0);
    SQL
  end
end
