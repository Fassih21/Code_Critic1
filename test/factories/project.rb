FactoryBot.define do
    factory :project do
        name {Faker::App.name}
        description {Faker::Lorem.sentence}
        user
    end
end