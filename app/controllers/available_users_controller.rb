class AvailableUsersController < ApplicationController

  expose_decorated(:users) { available_users }
  expose_decorated(:roles) { Role.technical }
  expose(:months_options) { months_select_options }
  expose(:selected_months) { params[:months] || "0" }

  def index; end

  private

  def available_users
    number_of = (params[:months] || 0).to_i
    @roles = Role.technical.to_a
    available_technical = User.active.available.roles(@roles)
    return available_technical unless number_of > 0
    in_a_project = User.in_a_project_for_over(number_of.months)
    (available_technical.to_a + in_a_project.to_a).uniq(&:_id)
  end

  def months_select_options
    options = { "Don't show" => 0 }
    (1..12).each do |n|
      key = n == 1 ? "#{n} month" : "#{n} months"
      options.merge!( key => n )
    end
    options
  end
end
