class AddMissionAdminToPointTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :point_transactions, :mission_admin, foreign_key: true, null: true

    # Allow merchant_id to be nullable so that either merchant OR mission_admin can be recorded
    change_column_null :point_transactions, :merchant_id, true
  end
end
