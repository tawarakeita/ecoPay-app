class CreateKioskDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :kiosk_devices do |t|
      t.string :device_uid
      t.string :name
      t.boolean :enabled
      t.references :merchant, null: false, foreign_key: true
      t.references :mission_admin, null: false, foreign_key: true

      t.timestamps
    end
    add_index :kiosk_devices, :device_uid
  end
end
