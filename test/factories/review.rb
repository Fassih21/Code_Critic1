FactoryBot.define do
    factory :review do
        status { "approved" }
        result { "Code looks good!" }
        code_file 
    end 
end