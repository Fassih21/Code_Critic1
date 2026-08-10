require "rails_helper"

RSpec.describe CodeFile, type: :model do
    describe "associations" do
        it {should belong_to(:project)}
        it {should have_one(:review).dependent(:destroy)}
        it {should have_one_attached(:file)}
    end
    describe "validations" do
    it "is invalid without file or content" do
      code_file = build(:code_file, file: nil, content: nil)
      expect(code_file).not_to be_valid
      expect(code_file.errors[:base]).to include("You must provide either a file or paste code")
    end

    it "is valid with content but no file" do
      code_file = build(:code_file, file: nil, content: "puts 'hello'")
      expect(code_file).to be_valid
        end
    end
end

