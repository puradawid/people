FactoryGirl.define do
  factory :role do
    name { Faker::Name.name }
    billable 0

    factory :role_invalid do
      name nil
    end

    factory :role_billable do
      name 'senior'
      billable 1
      technical true
    end

    factory :pm_role do
      name 'pm'
      technical false
    end

    factory :role_admin do
      name 'senior'
      admin true
    end

    factory :junior_role do
      name 'junior'
    end

    factory :technical_role do
      technical true
    end

    factory :qa_role do
      name 'qa'
    end
  end
end
