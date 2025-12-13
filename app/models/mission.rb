require "openssl"
require "base64"

class Mission < ApplicationRecord
  belongs_to :mission_admin, optional: true
  belongs_to :merchant, optional: true

  before_validation :generate_unique_code, on: :create
  validates :unique_code, presence: true, uniqueness: true

  private

  def generate_unique_code
    return if unique_code.present?

    begin
      self.unique_code = SecureRandom.hex(8)
    end while self.class.exists?(unique_code: unique_code)
  end
end