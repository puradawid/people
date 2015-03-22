require 'spec_helper'

describe 'Projects page', js: true do
  let(:senior_role) { create(:admin_role) }
  let!(:user) { create(:user, admin_role_id: senior_role.id) }
  let!(:active_project) { create(:project) }
  let!(:potential_project) { create(:project, :potential) }
  let!(:archived_project) { create(:project, :archived) }
  let!(:pm_user) { create(:pm_user) }
  let!(:qa_user) { create(:qa_user) }
  let!(:note) { create(:note) }

  before do
    allow_any_instance_of(SendMailJob).to receive(:perform)
    page.set_rack_session 'warden.user.user.key' => User.serialize_into_session(user).unshift('User')
    visit '/dashboard' # Projects tab
  end

  describe 'tabs' do
    it 'has Active/Potential/Archived tabs' do
      within('#filters') do
        page.find('li.active').click
        page.find('li.potential').click
        page.find('li.archived').click
      end
    end
  end

  describe 'project row' do
    context 'when on Active tab' do
      it 'displays action icons (timelapse) when hovered' do
        within('#filters') { page.find('li.active').click }

        within('.project') do
          expect(page.find('.unarchive', visible: false)).to_not be_visible
          expect(page.find('.archive')).to be_visible
          expect(page.find('.info.js-timeline-show')).to be_visible
        end
      end
    end

    context 'when on Potential tab' do
      it 'displays action icons (archive, timelapse) when hovered' do
        page.find('li.potential').click
        within('.project.potential') do
          expect(page.find('.unarchive', visible: false)).to_not be_visible
          expect(page.find('.archive')).to be_visible
          expect(page.find('.info.js-timeline-show')).to be_visible
        end
      end
    end

    context 'when on Archived tab' do
      it 'displays action icons (unarchive, timelapse) when hovered' do
        page.find('li.archived').click
        within('.project.archived') do
          expect(page.find('.unarchive')).to be_visible
          expect(page.find('.archive', visible: false)).to_not be_visible
          expect(page.find('.info.js-timeline-show')).to be_visible
        end
      end
    end
  end

  describe 'project adding' do
    before do
      find('button.new-project-add').click
    end

    context 'when adding valid project' do
      it 'creates new project' do
        find_by_id('project-name').set('Project1')
        find_by_id('project-slug').set('test')
        find('label[for=kickoff]').click
        find('.datepicker .today.day').click
        find_by_id('end-at').set('2020-02-02')
        find_by_id('project-type').set('Regular')
        check('Potential')
        find('div.selectize-control.devs .selectize-input').click
        first('div.selectize-dropdown-content [data-selectable]').click
        find('div.selectize-control.pms .selectize-input').click
        first('div.selectize-dropdown-content [data-selectable]').click
        find('div.selectize-control.qas .selectize-input').click
        first('div.selectize-dropdown-content [data-selectable]').click
        find('button.new-project-submit').click
        expect(page).to have_content('Project1')
      end
    end

    context 'when adding invalid project' do

      context 'when name is invalid' do
        it 'fails with error message' do
          find_by_id('project-name').set('test test')
          find_by_id('project-slug').set('test')
          find('button.new-project-submit').click
          expect(page.find('.message-error')).to be_visible
        end
      end
      
      context 'when slug is invalid' do
        it 'fails with message error' do
          find_by_id('project-name').set('test')
          find_by_id('project-slug').set('tEsT')
          find('button.new-project-submit').click
          expect(page.find('.message-error')).to be_visible
        end
      end
    end
  end

  describe 'managing notes' do

    describe 'add a new note' do

      before do
        within('div.project') do
        first('div.show-notes').click
        end
      end

      it 'add a note to the project' do
        find('input.new-project-note-text').set('Test note')
        find('a.new-project-note-submit').click
        expect(page.find('div.scroll-overflow', text: 'Test note')).to be_visible
      end
    end

    describe 'remove note' do

      before do
        create(:note, user: pm_user, project: active_project)
        visit '/dashboard'
        within('div.project') do
        first('div.show-notes').click
        end
      end

      it 'remove a note' do
        expect(page.find('div.scroll-overflow', text: note.text)).to be_visible
        find('span.note-remove').click
        expect(page.find('.alert-success')).to be_visible
      end
    end
  end
end
