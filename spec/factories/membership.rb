FactoryGirl.define do
  factory :membership do
    starts_at { Time.now }
    ends_at { starts_at + 1.month }
    user
    project
    role
    billable 0

    factory :membership_without_ends_at do
      ends_at nil
    end

    factory :membership_billable do
      billable 1
    end
  end
end

