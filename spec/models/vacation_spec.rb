require 'spec_helper'

describe Vacation do
  subject { build(:vacation) }

  it { should belong_to :user }
  it { should have_field(:starts_at).of_type(Date)}
  it { should have_field(:ends_at).of_type(Date)}
  it { should validate_presence_of(:starts_at) }
  it { should validate_presence_of(:ends_at) }
  it { should be_valid }
end
