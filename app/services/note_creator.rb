class NoteCreator
  attr_reader :note

  def initialize(note)
    @note = note
  end

  def call!
    note_saved = note.save
    send_notification_email if note_saved
    note_saved
  end

  private

  def send_notification_email
    SendMailJob.new.async.perform(NoteMailer, :note_added, note)
  end
end
