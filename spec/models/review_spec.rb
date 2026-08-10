require "rails_helper"
RSpec.describe Review, type: :model do
    describe "assocation" do
        it{should belong to(:codefile)}
        it{should have_many(:comments).dependent(:destroy)}
    end

    describe "validation" do
        review = build(:review)
        it{should validate_presence_of(:status)}
        it{should validate_presence_of(:result)}
    end
end
