attributes :id, :name, :archived, :potential, :end_at, :colour, :initials

child :notes do
  extends 'notes/base'
end
