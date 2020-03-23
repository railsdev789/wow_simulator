class ModifierTracker < Tracker
  def initialize(options)
    @talents = options[:talents]
    @activated_items = options[:activated_items]
    @mana_regen = options[:mana_regen]
  end
end

# modifier_options = {:talents => {}, :activated_items => {}}

# Gear Set 1
  # mana1
  # int1
  # spirit1
  # mp51
  # spell_damage1
  # hit1
  # crit1

  # mana_regen
  # gems
  # pots
  # runes
  # robe_of_archmage
  # evocate

  # Activated Items
  # talisman
  # mind_quickening_gem

  # Set Bonuses
  # tier1_3pc
  # tier2_8pc
  # pvp_2pc

  # Talents
  # arcane_power
  # arcane_concentration
  # arcane_instability
  # arcane_meditation
  # arcane_mind
  # frost_channeling
  # ice_shards
  # improved_frostbolt
  # piercing_ice
  # presence_of_mind

  # Debuffs
  # nightfall
  # winters_chill

  # Buffs
  # arcane_intellect
  # mage_armor
  # moonkin_form
  # rallying_cry
  # songflower_serenade
  # warchiefs_blessing
  # dmf_damage
  # dmf_intellect
  # dmf_spirit
  # dmn_slipkik
  # blessing_blackfathom

  # Consumables
  # nightfin_soup
  # run_tum_tuber_surprise
  # blessed_sunfruit_juice
  # greater_arcane_elixir
  # arcane_elixir
  # elixir_frost_power
  # flask_supreme_power
  # flask_distilled_wisdom
  # blasted_intellect
  # blasted_spirit