class NotesController < ApplicationController

  expose :note, attributes: :note_params

  before_filter :authenticate_admin!

  def create
    if note.save
      NoteMailer.note_added(note).deliver
      respond_on_success 'create'
    else
      respond_on_failure 'create'
    end
  end

  def show
  end

  def update
    if note.save
      respond_on_success 'update'
    else
      respond_on_success 'update'
    end
  end

  def destroy
    if note.destroy
      respond_to do |format|
        format.html { redirect_to note, notice: 'Note deleted!' }
        format.json { render json: { }, status: 204 }
      end
    else
      respond_to do |format|
        format.html { redirect_to note, alert: 'Something went wrong. Destroy unsuccessful.' }
        format.json { render json: { errors: note.errors }, status: 400 }
      end
    end
  end

  private

  def respond_on_success(action_type)
    respond_to do |format|
      format.html { redirect_to note, notice: I18n.t('notes.success', type: action_type)}
      format.json { render :show }
    end
  end

  def respond_on_failure(action_type)
    respond_to do |format|
      format.html { render :new, alert: I18n.t('notes.error', type: action_type)}
      format.json { render json: { errors: note.errors }, status: 400 }
    end
  end

  def note_params
    params.require(:note).permit(:text, :open, :project_id, :user_id)
  end
end
