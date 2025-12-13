class KioskDevice < ApplicationRecord
  belongs_to :merchant
  belongs_to :mission_admin
  before_create :generate_uid

  private
  def generate_uid
    self.device_uid ||= SecureRandom.hex(4)
  end
end
