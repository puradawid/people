require 'spec_helper'

describe Ability do
  subject { build(:ability) }

  it { should have_and_belong_to_many :users }
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should be_valid }
  it { should have_field(:name) }

  describe "#to_s" do
    it "returns name" do
      subject.name = "Ruby on Rails"
      expect(subject.to_s).to eq("Ruby on Rails")
    end
  end
end
