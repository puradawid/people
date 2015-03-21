FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    password { Devise.friendly_token[0, 20] }
    gh_nick { Faker::Name.first_name }
    employment { 100 }
    available false
    without_gh false
    oauth_token '123'
    gravatar { File.open(Rails.root.join('spec', 'fixtures', 'gravatar', 'gravatar.jpg')) }
    user_notes { Faker::Lorem.sentence }
    primary_role { create(:technical_role) }

    factory :user_deleted do
      deleted_at Time.now
    end

    trait :available do
      available true
      available_since { Date.today }
    end
  end

  factory :junior_dev, class: "User" do
    first_name 'Jan'
    last_name 'Kowalski'
    email 'jan.kowalski@example.com'
    password 'netguru123'
    without_gh true
  end
end
