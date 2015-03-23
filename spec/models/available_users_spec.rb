describe AvailableUsers do
  let(:available_user) { create(:user, :available) }
  let(:unavailable_user) { create(:user) }

  subject { AvailableUsers.new.all }

  it 'returns only available users' do
    expect(subject).to include available_user
    expect(subject).not_to include unavailable_user
  end
end
