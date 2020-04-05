class Player
  attr_accessor :options, :selected_class, :mana, :intelligence, :spirit, :mp5, :spell_damage, :spell_hit_chance, :spell_crit_chance, 
                :spell_mana_cost, :spell_min_damage, :spell_max_damage, :spell_casting_time, :spell_coefficient,
                :combat_mana_regen, :mana_multiplier, :mana_cost_multiplier, :spell_damage_multiplier, :spell_crit_multiplier, :spell_casting_time_multiplier,
                :set_bonuses, :permanent_talents, :buffs, :debuffs, :consumables, :spell, :gear_set1

  def initialize(options)
    @selected_class = options[:selected_class]

    @mana = options[:gear_set1][:mana].to_i
    @base_mana = @mana
    @intelligence = options[:gear_set1][:intelligence].to_i
    @base_intelligence = @intelligence
    @spirit = options[:gear_set1][:spirit].to_i
    @base_spirit = @spirit
    @mp5 = options[:gear_set1][:mp5].to_i
    @base_mp5 = @mp5
    @spell_damage = options[:gear_set1][:spell_damage].to_i
    @spell_hit_chance = (options[:gear_set1][:spell_hit_chance].to_i / 100.0) + 0.84
    @base_spell_hit_chance = @spell_hit_chance
    @spell_crit_chance = ((options[:gear_set1][:spell_crit_chance].to_i / 100.0) + (@intelligence / 5950.0)).round(4)
    @base_spell_crit_chance = @spell_crit_chance

    @spell_mana_cost = options[:spell][:mana_cost]
    @spell_min_damage = options[:spell][:min_damage]
    @spell_max_damage = options[:spell][:max_damage]
    @spell_casting_time = options[:spell][:spell_casting_time]
    @spell_coefficient = options[:spell][:coefficient]
    
    @combat_mana_regen = 0.0
    @mana_multiplier = 1.0
    @mana_cost_multiplier = 1.0
    @spell_damage_multiplier = 1.0
    @spell_crit_multiplier = 1.5
    @spell_casting_time_multiplier = 1.0
    @intelligence_multiplier = 1.0
    @spirit_multiplier = 1.0
    # @spell_total_damage_multiplier = 1.0

    @set_bonuses = options[:set_bonuses]
    @permanent_talents = options[:permanent_talents]
    @buffs = options[:buffs]
    @debuffs = options[:debuffs]
    @consumables = options[:consumables]
    @spell = options[:spell]
    @gear_set1 = options[:gear_set1]

    @options = options
    @output_logger = options[:output_logger]
    # update_player_attributes
    puts "player options:#{options}"
    initial_setup
  end

  def options
    @options
  end

  def round_values
    [:mana, :intelligence, :spirit, :mp5, :spell_damage, :spell_hit_chance, :spell_crit_chance, 
     :spell_mana_cost, :spell_min_damage, :spell_max_damage, :spell_casting_time, :spell_coefficient,
     :combat_mana_regen, :mana_multiplier, :mana_cost_multiplier, :spell_damage_multiplier, :spell_crit_multiplier, 
     :spell_casting_time_multiplier].each do |method|
      instance_variable_set("@#{method}", eval(method.to_s).round(4))
     end
  end

  def initial_setup
    log_attributes(["Initial Player Attributes", "Initial Spell Attributes"])
    update_player_attributes_with_talents_and_set_bonuses
    round_values
    log_attributes(["Player Attributes after Talents and Set Bonuses Applied", "Spell Attributes after Talents and Set Bonuses Applied"])
    update_player_attributes_with_buffs_and_consumables
    round_values
    log_attributes(["Player Attributes after Talents, Set Bonuses, Buffs and Consumables Applied", "Spell Attributes after Talents, Set Bonuses, Buffs and Consumables Applied"])
  end

  def log_attributes(strings)
    output = ""
    player_attribute_array = @gear_set1.keys + [:combat_mana_regen, :mana_multiplier, :mana_cost_multiplier, :spell_damage_multiplier, :spell_crit_multiplier, :spell_casting_time_multiplier]
    player_attribute_array.each do |attribute|
      output += "#{attribute.to_s.humanize.titleize}: #{eval(attribute.to_s)};"
    end

    @output_logger.log(strings[0], output)

    spell_output = ""
    [:spell_mana_cost, :spell_min_damage, :spell_max_damage, :spell_casting_time, :spell_coefficient].each do |attribute|
      spell_output += "#{attribute.to_s.humanize.titleize}: #{eval(attribute.to_s)};"
    end

    @output_logger.log(strings[1], spell_output)
  end

  def update_player_attributes_with_talents_and_set_bonuses
    #TODO: refactor to use dynamic programming
    #TALENTS
    if (@options[:permanent_talents].keys.include?(:arcane_mind))
      @mana_multiplier *= @options[:permanent_talents][:arcane_mind][:amount]
    end

    if (@options[:permanent_talents].keys.include?(:arcane_concentration))
      @mana_cost_multiplier *= @options[:permanent_talents][:arcane_concentration][:amount]
    end

    if (@options[:permanent_talents].keys.include?(:arcane_instability))
      @spell_crit_chance += @options[:permanent_talents][:arcane_instability][:modifier][:spell_crit_chance]
      @spell_damage_multiplier *= @options[:permanent_talents][:arcane_instability][:modifier][:spell_damage_multiplier]
    end

    if (@options[:permanent_talents].keys.include?(:arcane_meditation))
      @combat_mana_regen += @options[:permanent_talents][:arcane_meditation][:amount]
    end

    if (@options[:permanent_talents].keys.include?(:frost_channeling))
      @mana_cost_multiplier *= @options[:permanent_talents][:frost_channeling][:amount]
    end

    if (@options[:permanent_talents].keys.include?(:ice_shards))
      @spell_crit_multiplier += @options[:permanent_talents][:ice_shards][:amount]
    end

    if (@options[:permanent_talents].keys.include?(:improved_frostbolt))
      @spell_casting_time += @options[:permanent_talents][:improved_frostbolt][:amount]
    end

    if (@options[:permanent_talents].keys.include?(:piercing_ice))
      @spell_damage_multiplier *= @options[:permanent_talents][:piercing_ice][:amount]
    end

    #SET BONUSES
    if (@options[:set_bonuses].keys.include?(:mage_tier1_3pc))
      @spell_damage += @options[:set_bonuses][:mage_tier1_3pc][:amount]
    end

    if (@options[:set_bonuses].keys.include?(:mage_tier2_8pc))
      @spell_casting_time_multiplier *= @options[:set_bonuses][:mage_tier2_8pc][:amount]
    end

    if (@options[:set_bonuses].keys.include?(:mage_rare_pvp_2pc))
      @spell_damage += @options[:set_bonuses][:mage_rare_pvp_2pc][:amount]
    end

    if (@options[:set_bonuses].keys.include?(:mage_epic_pvp_6pc))
      @spell_damage += @options[:set_bonuses][:mage_epic_pvp_6pc][:amount]
    end
  end

  def update_player_attributes_with_buffs_and_consumables
    #BUFFS
    if (@options[:buffs].keys.include?(:dmf_intellect))
      @intelligence_multiplier *= @options[:buffs][:dmf_intellect][:amount]
      @intelligence *= @intelligence_multiplier
      intelligence_difference = @intelligence - @base_intelligence
      @mana = (@mana + (intelligence_difference * 15 * @mana_multiplier)).round
      @spell_crit_chance = (@spell_crit_chance + (intelligence_difference / 5950.0)).round(4)
    end

    if (@options[:buffs].keys.include?(:arcane_intellect))
      @intelligence += @options[:buffs][:arcane_intellect][:amount]
      intelligence_difference = @options[:buffs][:arcane_intellect][:amount]
      @mana = (@mana + (intelligence_difference * 15 * @mana_multiplier)).round
      @spell_crit_chance = (@spell_crit_chance + (intelligence_difference / 5950.0)).round(4)
    end

    if (@options[:buffs].keys.include?(:mage_armor))
      @combat_mana_regen += @options[:buffs][:mage_armor][:amount]
    end

    if (@options[:buffs].keys.include?(:moonkin_form))
      @spell_crit_chance += @options[:buffs][:moonkin_form][:amount]
    end

    if (@options[:buffs].keys.include?(:rallying_cry))
      @spell_crit_chance += @options[:buffs][:rallying_cry][:amount]
    end

    if (@options[:buffs].keys.include?(:songflower_serenade))
      @spell_crit_chance += @options[:buffs][:songflower_serenade][:modifier][:spell_crit_chance]
      @intelligence += @options[:buffs][:songflower_serenade][:modifier][:intelligence]
      @spirit += @options[:buffs][:songflower_serenade][:modifier][:spirit]
      intelligence_difference = @options[:buffs][:songflower_serenade][:modifier][:intelligence]
      @mana = (@mana + (intelligence_difference * 15 * @mana_multiplier)).round
      @spell_crit_chance = (@spell_crit_chance + (intelligence_difference / 5950.0)).round(4)
    end

    if (@options[:buffs].keys.include?(:warchiefs_blessing))
      @mp5 += @options[:buffs][:warchiefs_blessing][:amount]
    end

    if (@options[:buffs].keys.include?(:dmf_damage))
      @spell_damage_multiplier *= @options[:buffs][:dmf_damage][:amount]
    end

    if (@options[:buffs].keys.include?(:dmf_spirit))
      @spirit_multiplier *= @options[:buffs][:dmf_spirit][:amount]
    end

    if (@options[:buffs].keys.include?(:dmn_slipkik))
      @spell_crit_chance += @options[:buffs][:dmn_slipkik][:amount]
    end

    if (@options[:buffs].keys.include?(:blessing_blackfathom))
      @intelligence += @options[:buffs][:blessing_blackfathom][:modifier][:intelligence]
      @spirit += @options[:buffs][:blessing_blackfathom][:modifier][:spirit]
      @spell_damage += @options[:buffs][:blessing_blackfathom][:modifier][:spell_damage]
      intelligence_difference = @options[:buffs][:blessing_blackfathom][:modifier][:intelligence]
      @mana = (@mana + (intelligence_difference * 15 * @mana_multiplier)).round
      @spell_crit_chance = (@spell_crit_chance + (intelligence_difference / 5950.0)).round(4)
    end

    #DEBUFFS
    if (@options[:debuffs].keys.include?(:nightfall))
      @spell_damage_multiplier *= @options[:debuffs][:nightfall][:amount]
    end

    if (@options[:debuffs].keys.include?(:winters_chill))
      @spell_crit_chance += @options[:debuffs][:winters_chill][:amount]
    end

    #CONSUMABLES
    if (@options[:consumables].keys.include?(:nightfin_soup))
      @mp5 += @options[:consumables][:nightfin_soup][:amount]
    end

    if (@options[:consumables].keys.include?(:run_tum_tuber_surprise))
      @intelligence += @options[:consumables][:run_tum_tuber_surprise][:amount]
      intelligence_difference = @options[:consumables][:run_tum_tuber_surprise][:amount]
      @mana = (@mana + (intelligence_difference * 15 * @mana_multiplier)).round
      @spell_crit_chance = (@spell_crit_chance + (intelligence_difference / 5950.0)).round(4)
    end

    if (@options[:consumables].keys.include?(:blessed_sunfruit_juice))
      @spirit += @options[:consumables][:blessed_sunfruit_juice][:amount]
    end

    if (@options[:consumables].keys.include?(:greater_arcane_elixir))
      @spell_damage += @options[:consumables][:greater_arcane_elixir][:amount]
    end

    if (@options[:consumables].keys.include?(:arcane_elixir))
      @spell_damage += @options[:consumables][:arcane_elixir][:amount]
    end

    if (@options[:consumables].keys.include?(:elixir_frost_power))
      @spell_damage += @options[:consumables][:elixir_frost_power][:amount]
    end

    if (@options[:consumables].keys.include?(:flask_supreme_power))
      @spell_damage += @options[:consumables][:flask_supreme_power][:amount]
    end

    if (@options[:consumables].keys.include?(:flask_distilled_wisdom))
      @mana += @options[:consumables][:flask_distilled_wisdom][:amount]
    end

    if (@options[:consumables].keys.include?(:blasted_intellect))
      @intelligence += @options[:consumables][:blasted_intellect][:amount]
      intelligence_difference = @options[:consumables][:blasted_intellect][:amount]
      @mana = (@mana + (intelligence_difference * 15 * @mana_multiplier)).round
      @spell_crit_chance = (@spell_crit_chance + (intelligence_difference / 5950.0)).round(4)
    end

    if (@options[:consumables].keys.include?(:blasted_spirit))
      @spirit += @options[:consumables][:blasted_spirit][:amount]
    end
  end
end