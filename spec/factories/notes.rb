FactoryGirl.define do
  factory :note do
    text Faker::Address.city
    open true
  end
end
