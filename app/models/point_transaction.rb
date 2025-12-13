class PointTransaction < ApplicationRecord
  belongs_to :user
  belongs_to :merchant, optional: true
  belongs_to :mission, optional: true
  belongs_to :mission_admin, optional: true
end
