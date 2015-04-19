attributes :id, :name, :archived, :potential, :end_at, :colour, :initials, :internal, :last_commit_date

child :notes do
  extends 'notes/base'
end
