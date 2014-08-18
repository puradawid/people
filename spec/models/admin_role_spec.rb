describe AdminRole do
  subject { build(:admin_role) }

  it { should have_many :users }
end
