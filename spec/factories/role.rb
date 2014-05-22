FactoryGirl.define do
  factory :role do
    name { Faker::Name.name }
    billable 0

    factory :role_invalid do
      name nil
    end

    factory :role_billable do
      name { %w(senior developer).sample }
      billable 1
    end
  end
end
