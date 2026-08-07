FactoryBot.define do
    factory :code_file do
        content { "puts 'hello world'" }
        language { Faker::ProgrammingLanguage.name }
        project
    end
end
