require 'spec_helper'
require 'rake'

describe AvailabilityChecker do
  let!(:user) { create(:user, role: role, available: nil) }
  let(:role) { create(:role, technical: true) }

  describe 'people namespace rake task' do
    before :all do
      Rake.application.rake_require 'tasks/people'
      Rake::Task.define_task(:environment)
    end

    describe 'people:AvailabilityChecker' do

      let :run_rake_task do
        Rake::Task['people:available_checker'].reenable
        Rake.application.invoke_task 'people:available_checker'
      end

      it 'should receive perform' do
        expect_any_instance_of(AvailabilityCheckerJob).to receive(:perform).once
        run_rake_task
      end
    end
  end
end