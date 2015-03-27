shared_context 'trello' do
  subject { described_class.new(board) }

  let(:board) { Trello::Board.find AppConfig.trello.schedule_board_id }
  let(:board_id) { AppConfig.trello.schedule_board_id }
  let(:key) { AppConfig.trello.developer_public_key }
  let(:token) { AppConfig.trello.member_token }

  before do
    stub_request(
      :get,
      "https://api.trello.com/1/boards/#{board_id}?key=#{key}&token=#{token}"
    ).to_return(
      status: 200,
      body: File.open(Rails.root.join('spec', 'fixtures', 'trello', 'board.json')),
      headers: {}
    )

    stub_request(
      :get,
      "https://api.trello.com/1/boards/5512a4c856f2ded676f66138/cards?filter=open&key=#{key}&token=#{token}"
    ).to_return(
      status: 200,
      body: File.open(Rails.root.join('spec', 'fixtures', 'trello', 'cards.json')),
      headers: {}
    )
  end
end
