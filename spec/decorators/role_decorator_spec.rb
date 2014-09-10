require 'spec_helper'

describe RoleDecorator do
  let(:role) { create(:role).decorate }

  describe '#label' do
    it { expect(role.label).to eq("<span class=\"label label-default\" style=\"background-color: \">#{role.name.html_safe}</span>") }
  end
end
