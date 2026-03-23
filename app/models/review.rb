class Review < ApplicationRecord
  belongs_to :code_file
  has_many :comments, dependent: :destroy

  validates :status, presence: true
  validates :result, presence: true
end