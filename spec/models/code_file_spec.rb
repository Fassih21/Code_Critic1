require "rails_helper"

RSpec.describe CodeFile, type: :model do
    describe "associations" do
        it {should belong_to(:project)}
        it {should have_one(:review).dependent(:destroy)}
        it {should have_one_attached(:file)}
    end
    describe "validations" do
        code_file = build(:code_file)
        it {should validate_presence_of(:name)}
        it {should validate_presence_of(:file)}
    end
end
