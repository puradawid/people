class AbilitiesController < ApplicationController
  include ContextFreeRepos

  expose(:ability, attributes: :ability_params)
  expose(:abilities) { abilities_repository.all }

  before_filter :authenticate_admin!

  def index
  end

  def create
    if ability.save
      redirect_to abilities_path, notice: 'Ability created!'
    else
      render :new, alert: 'Something went wrong. Create unsuccessful'
    end
  end

  def update
    if ability.save
      redirect_to abilities_path, notice: 'Ability updated!'
    else
      render :edit, alert: 'Something went wrong. Update unsuccessful'
    end
  end

  def destroy
    if ability.destroy
      redirect_to abilities_path, notice: 'Ability deleted!'
    else
      redirect_to abilities_path, alert: 'Something went wrong. Delete unsuccessful'
    end
  end

  private

  def ability_params
    params.require(:ability).permit(:name, :icon, :remove_icon)
  end
end
