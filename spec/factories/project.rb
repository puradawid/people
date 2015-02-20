FactoryGirl.define do
  factory :project do
    sequence(:name) { |i| "#{Faker::Internet.domain_word}_#{i}" }
    slug { name.try(:downcase).try(:tr, '^a-z0-9', '') }
    end_at { 30.days.from_now }
    archived false

    factory :project_deleted do
      deleted_at Time.now
    end

    factory :invalid_project do
      name nil
    end

    trait :potential do
      potential true
    end

    trait :archived do
      archived true
    end
  end
end
