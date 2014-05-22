FactoryGirl.define do
  factory :ability do
    name { Faker::Name.name }

    factory :ability_invalid do
      name nil
    end
  end
end
