class Comment < ApplicationRecord
  belongs_to :review
  belongs_to :user
  
  validates :content, presence: :true
  validates :line_number, presence: :true
end
