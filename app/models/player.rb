class Player
  attr_accessor :options

  def initialize(options)
    @class = options[:class]
    @mana = options[:mana]
    @intelligence = options[:intelligence]
    @spirit = options[:spirit]
    @mp5 = options[:mp5]
    @spell_damage = options[:spell_damage]
    @hit_chance = options[:hit_chance]
    @crit_chance = options[:crit_chance]
    @spell_mana_cost = options[:spell][:mana_cost]
    @spell_min_damage = options[:spell][:min_damage]
    @spell_max_damage = options[:spell][:max_damage]
    @spell_casting_time = options[:spell][:casting_time]
    @spell_coefficient = options[:spell][:coefficient]
    @set_bonuses = options[:set_bonuses]
    @talents = options[:talents]
    @buffs = options[:buffs]
    @debuffs = options[:debuffs]
    @consumables = options[:consumables]

    @options = options
    # update_player_attributes
  end

  def options
    @options
  end

  def update_player_attributes
    if (options[:use_arcane_meditation])
      combat_mana_regen_factor += 0.15
    end

    if (options[:use_mage_armor])
      combat_mana_regen_factor += 0.30
    end

    if (options[:use_nightfall])
      total_damage_factor *= 1.15
    end

    if (options[:use_arcane_instability])
      total_damage_factor *= 1.03
      modified_crit_chance += 0.03
    end

    if (options[:use_piercing_ice])
      total_damage_factor *= 1.06
    end

    if (options[:use_nightfin_soup])
      mp5 += 8.0
    end

    if (options[:use_moonkin_form])
      modified_crit_chance += 0.03
    end

    if (options[:use_winters_chill])
      modified_crit_chance += 0.10
    end

    if (options[:use_greater_arcane_elixir])
      plus_damage += 35.0
    end

    if (options[:use_greater_arcane_elixir])
      plus_damage += 20.0
    end

    if (options[:use_frost_power_elixir])
      plus_damage += 15.0
    end

    if (options[:use_arcane_intellect])
      intelligence += 31.0
      mana_factor = options[:use_arcane_mind] ? 1.15 : 1.0
      base_mana += ((15.0 * 31.0) * mana_factor).round
    end

    if (options[:use_spirit_buff])
      spirit += 40.0
    end

    if (options[:use_improved_frostbolt])
      modified_cast_time -= 0.5
    end

    if (options[:use_frost_channeling])
      modified_mana_per_cast = (modified_mana_per_cast * 0.85).round
    end

    if (options[:use_arcane_concentration])
      modified_mana_per_cast = (modified_mana_per_cast * 0.90).round
    end    
  end
end