require 'spec_helper'

describe RoleDecorator do
  let!(:role) { create(:role).decorate }

  describe '#label' do
    it 'generates proper label' do
      label = "<span class=\"label label-default\" style=\"background-color: \">#{role.name}</span>"
      expect(role.label).to eq(label)
    end
  end
end
