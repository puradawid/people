attributes :id, :name, :archived, :potential, :end_at, :colour, :initials, :internal

child :notes do
  extends 'notes/base'
end
