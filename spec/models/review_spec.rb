require "rails_helper"
RSpec.describe Review, type: :model do
    describe "association" do
        it{should belong_to(:code_file)}
        it{should have_many(:comments).dependent(:destroy)}
    end

    describe "validation" do
        it{should validate_presence_of(:status)}
        it{should validate_presence_of(:result)}
    end
end
