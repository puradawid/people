attributes :id, :name, :archived, :potential, :end_at

child :notes do
  extends 'notes/base'
end
