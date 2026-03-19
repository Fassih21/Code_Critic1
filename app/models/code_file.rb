class CodeFile < ApplicationRecord

  belongs_to :project
 
  has_one  :review, dependent: :destroy
  has_one_attached :file

  

  validates :content, presence: :true
  validates :language, presence: :true
end
