class User < ApplicationRecord
  
  has_many :projects, dependent: :destroy
  has_many :comments, dependent: :destroy

  before_save :normalize_name

  validates :name, presence: true
  validates :email, presence: true, uniqueness: :true
  validates :password, format: {
    with: /\A
    (?=.*[a-z])
    (?=.*[A-Z])
    (?=.*\d)
    (?=.*[!@#$%^&*])
    /x,
    message: "must include at least one uppercase letter, one lowercase letter, one number, and one special character (!@#$%^&*)"
  } if:->{ password.present? }
  
     def normalize_name
    self.name = name.strip.titleize if name.present?
  end

  devise :database_authenticatable, :registerable
         :recoverable, :rememberable, :validatable
end
