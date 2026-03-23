class CodeFile < ApplicationRecord
  belongs_to :project
  has_one :review, dependent: :destroy
  has_one_attached :file

  ACCEPTABLE_TYPES = %w[
    text/plain
    application/javascript
    application/x-ruby
    application/x-cpp
    application/x-py
  ].freeze

  validate :acceptable_file
  validate :content_or_file_present
  validates :language, presence: true

  private

  def acceptable_file
    return unless file.attached?

    errors.add(:file, "is too big") if file.byte_size > 200.kilobytes
    errors.add(:file, "must be a code file") unless ACCEPTABLE_TYPES.include?(file.content_type)
  end

  def content_or_file_present
    if !file.attached? && content.blank?
      errors.add(:base, "You must provide either a file or paste code")
    end
  end
end