require "rails_helper"

Rspec.describe User, type: :model do
    it "is valid with valid attibutes" do
        user = create(:user)
        expect(user).to be valid
    end
    
    describe "associations" do
        it {should have_many(:projects).dependent(:destroy)}
        it {should have_many(:comments).dependent(:destroy)}
        it {should have_one_attached(:avatar)}
    end

    describe "validations" do
        user = build(:user)
        it {should validate_presence_of(:name)}
        it {should validate_presence_of(:email)}
        it {should validate_presence_of(:password)}
    end

    describe "normalize_name" do
        it "normalizes the name before saving" do
            user = build(:user, name: "  john doe  ")
            user.save
            expect(user.name).to eq("John Doe")
        end
    end
end
