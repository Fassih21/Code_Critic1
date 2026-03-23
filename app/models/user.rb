class User < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :comments, dependent: :destroy

  before_save :normalize_name

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  validates :password,
    length: { minimum: 8 },
    format: {
      with: /\A
        (?=.*[a-z])
        (?=.*[A-Z])
        (?=.*\d)
        (?=.*[^A-Za-z0-9])
      /x,
      message: "must include uppercase, lowercase, number, and symbol"
    },
    if: -> { password.present? }

  def normalize_name
    self.name = name.strip.titleize if name.present?
  end

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end