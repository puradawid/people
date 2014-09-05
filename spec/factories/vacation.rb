FactoryGirl.define do
  factory :vacation do
    starts_at { Time.now-1.day }
    ends_at { Time.now+6.days }
    user
  end
end
