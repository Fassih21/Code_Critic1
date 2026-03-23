class Project < ApplicationRecord

  belongs_to :user
  has_many :code_files, dependent: :destroy
  
  validates :name, presence: true
  validates :description, presence: true


end
