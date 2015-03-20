class AbilitiesRepository
  def all
    Ability.all
  end

  def ordered_by_user_abilities (user)
    ability_ids = user.ability_ids
    not_found_index = ability_ids.count + 1
    all.sort_by { |sa| ability_ids.index(sa.id) || not_found_index }
  end
end
