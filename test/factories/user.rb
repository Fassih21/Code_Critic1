FactoryBot.define do
    factory :user do
        name { Faker::Name.name}
        password { "Password1!" }
        sequence(:email) { |n| "user#{n}@example.com" }
    end
end