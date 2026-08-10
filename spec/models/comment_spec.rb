require "rails_helper"
RSpec.describe Comment, type: :model do
    describe "assocation" do
        it{should belong_to(:review)}
        it{should belong_to(:user)}
    end
    describe "validation" do
        it{should validate_presence_of(:content)}
        it{should validate_presence_of(:line_number)}
    end
end