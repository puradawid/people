require 'spec_helper'
require 'carrierwave/test/matchers'

describe IconUploader do
  let(:ability) { build_stubbed(:ability) }
  subject { described_class.new(ability, 'image') }

  describe '#store_dir' do
    it { expect(subject.store_dir).to eq "uploads/ability/image/#{ability.id}" }
  end

  describe '#extension_white_list' do
    it { expect(subject.extension_white_list).to eq %w(jpg jpeg gif png) }
  end
end
