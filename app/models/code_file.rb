class CodeFile < ApplicationRecord

  belongs_to :project
  has_one :projects
  has_one  :review, dependent: :destroy
  has_one_attached :file
  has_many :comments
  
end
