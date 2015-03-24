class AvailableUsersController < ApplicationController
  expose(:users) { fetch_available_users }
  expose(:roles) { Role.all }
  expose(:abilities) { Ability.all }

  def index
    gon.users = Rabl.render(users, 'available_users/index', view_path: 'app/views', format: :hash)
    gon.roles = roles
    gon.abilities = abilities
    gon.availability_time = availability_time
  end

  private

  def fetch_available_users
    User
      .includes(:roles, :admin_role, :location, :contract_type, :memberships, :abilities)
      .technical.active.available.by_last_name.decorate
  end

  def availability_time
    result = []
    result << { value: 100_000, text: "All" }
    result << { value: 0, text: "From now" }
    result << { value: (1.week.from_now.to_date - Date.today).to_i, text: "1 week" }
    result << { value: (2.weeks.from_now.to_date - Date.today).to_i, text: "2 weeks" }
    result << { value: (4.weeks.from_now.to_date - Date.today).to_i, text: "4 weeks" }
    result << { value: (1.month.from_now.to_date - Date.today).to_i, text: "1 month" }
    result << { value: (2.months.from_now.to_date - Date.today).to_i, text: "2 months" }
    result << { value: (3.months.from_now.to_date - Date.today).to_i, text: "3 months" }
    result
  end
end
