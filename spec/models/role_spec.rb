describe Role do
  subject { build(:role) }

  it { should have_many :memberships }
  it { should validate_presence_of(:name) }
  it { should be_valid }
  it { should have_field(:name).of_type(String) }
  it { should have_field(:billable).of_type(Mongoid::Boolean).with_default_value_of(false) }
  it { should validate_inclusion_of(:billable).to_allow([true, false]) }

  describe "#to_s" do
    it "returns name" do
      subject.name = "junior"
      expect(subject.to_s).to eq("junior")
    end
  end
end
