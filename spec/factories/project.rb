FactoryGirl.define do
  factory :project do
    name { Faker::Internet.domain_word }
    end_at { 30.days.from_now }

    factory :project_deleted do
      deleted_at Time.now
    end

    factory :invalid_project do
      name nil
    end
  end
end
