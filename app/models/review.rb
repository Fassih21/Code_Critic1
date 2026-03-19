class Review < ApplicationRecord
  belongs_to :code_file
  has_many :comments, dependent: :destroy

  validates :content, presence: :true
  validates :line_number, presence: :true
end
