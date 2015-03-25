describe AvailableUsersRepository do
  let!(:available_user) { create(:user, :available) }
  let!(:archived_user) { create(:user, :available, :archived) }
  let!(:unavailable_user) { create(:user) }
  let!(:project_manager) do
    create(:user, :available, primary_role: create(:pm_role))
  end

  subject { described_class.new.all }

  it 'returns only available users' do
    expect(subject).to include available_user
    expect(subject).not_to include unavailable_user
  end

  it 'returns only technical users' do
    expect(subject).not_to include project_manager
  end

  it 'returns only active users' do
    expect(subject).not_to include archived_user
  end
end
