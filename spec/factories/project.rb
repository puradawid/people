FactoryGirl.define do
  factory :project do
    sequence(:name) { |i| "#{Faker::Internet.domain_word}_#{i}" }
    slug { name.try(:downcase).try(:tr, '^a-z', '') }
    end_at { 30.days.from_now }

    factory :project_deleted do
      deleted_at Time.now
    end

    factory :invalid_project do
      name nil
    end
  end
end
