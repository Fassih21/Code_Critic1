class Project < ApplicationRecord

  belongs_to :user
  has_many :code_files, dependent: :destroy
  
end
