class Review < ApplicationRecord
  belongs_to :code_file
  has_many :comments, dependent: :destroy
end
