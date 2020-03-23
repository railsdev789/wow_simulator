class PagesController < ApplicationController
  def simulate
    puts "TESTING: #{params}"
    # TODO: split activated talents from regular talents

    gear_set_1_keys = [:mana1, :int1, :spirit1, :mp51, :damage1, :hit1, :crit1]

    if (request.post?)
      simulations = {}
      
      player_options = {:set_bonuses => {}, :talents => {}, :buffs => {}, :debuffs => {}, :consumables => {}}
      modifier_options = {:talents => {}, :activated_items => {}, :mana_regen => {}}

      durations = params.fetch(:durations, ["60"]).map(&:to_i)

      player_options.keys.each do |key|
        params.fetch(key, []).each do |option|
          if ((key == :talents) && (References::TALENTS[params[:select_class].to_sym][option.to_sym][:activated] == false))
            player_options[key][option.to_sym] = "References::#{key.upcase}".constantize[params[:select_class].to_sym][option.to_sym]
          elsif key != :talents
            player_options[key][option.to_sym] = "References::#{key.upcase}".constantize[option.to_sym]
          end
        end
      end

      player_options.merge!({:class => params[:select_class], 
                             :gear_set1 => request.parameters[:gear_set1].symbolize_keys, 
                             :spell => References::SPELLS[params[:select_class].to_sym][request.parameters[:spell_ranks][0].split('_')[0].to_sym][request.parameters[:spell_ranks][0].to_sym]
                           })

      References::TALENTS[params[:select_class].to_sym].each do |talent, talent_options|
        if talent_options[:activated] == true && params.fetch(:talents, []).include?(talent.to_s)
          modifier_options[:talents].merge!({talent => talent_options})
        end
      end

      References::ACTIVATED_ITEMS.each do |item, item_options|
        if item_options[:classes].include?(params[:select_class].to_sym) && params.fetch(:activated_items, []).include?(item.to_s)
          modifier_options[:activated_items].merge!({item => item_options})
        end
      end

      References::MANA_REGEN.each do |item, item_options|
        if item_options[:classes].include?(params[:select_class].to_sym) && params.fetch(:mana_regen, []).include?(item.to_s)
          modifier_options[:mana_regen].merge!({item => item_options})
        end
      end

      puts "TEST1: #{player_options}"
      puts "TEST2: #{modifier_options}"
      puts "TEST3: #{durations}"
      puts "TEST4: #{params[:gear_set1]}"

      durations.each do |duration|
        simulations[duration] = Simulation.new({ :stop_time => duration, :player_options => player_options, :modifier_options => modifier_options})
      end
    end

    @mage_spells = References::SPELLS[:mage]
    @mana_regen = References::MANA_REGEN
    @activated_items = References::ACTIVATED_ITEMS
  end
end
# mana_regen
# activated_items
# set_bonuses
# talents
# buffs
# debuffs
# consumables
# Parameters: {"simulations"=>["single"], "select_class"=>"mage", "durations"=>["30", "60", "90", "120", "180", "240", "300", "360", "600"], "spell_ranks"=>["frostbolt_rank_1"], "mana1"=>"5000", "int1"=>"300", "spirit1"=>"200", "mp51"=>"30", "spell_damage1"=>"400", "hit_chance1"=>"5", "crit_chance1"=>"4", "mana_regen"=>["gems", "pots", "runes", "robe_of_archmage", "evocate"], "activated_items"=>["talisman", "mind_quickening_gem"], "set_bonuses"=>["tier1_3pc", "tier2_8pc", "pvp_2pc"], "talents"=>["arcane_power", "arcane_concentration", "arcane_instability", "arcane_meditation", "arcane_mind", "frost_channeling", "ice_shards", "improved_frostbolt", "piercing_ice", "presence_of_mind"], "debuffs"=>["nightfall", "winters_chill"], "buffs"=>["arcane_intellect", "mage_armor", "moonkin_form", "rallying_cry", "songflower_serenade", "warchiefs_blessing", "dmf_damage", "dmf_intellect", "dmf_spirit", "dmn_slipkik", "blessing_blackfathom"], "consumables"=>["nightfin_soup", "run_tum_tuber_surprise", "blessed_sunfruit_juice", "greater_arcane_elixir", "arcane_elixir", "elixir_frost_power", "flask_supreme_power", "flask_distilled_wisdom", "blasted_intellect", "blasted_spirit"]}


# def total_damage(options)
#   show_debugging = true
#   show_combat_ticks = true
#   base_mana = options[:base_mana]
#   intelligence = options[:intelligence]
#   spirit = options[:spirit]
#   plus_damage = options[:plus_damage]
#   mp5 = options[:mp5]
#   modified_hit_chance = (0.84 + options[:hit_chance_from_gear])
#   modified_crit_chance = (options[:crit_chance_from_gear] + ((intelligence / 59.5) / 100.0)).round(5)
#   fight_duration = options[:fight_duration]
#   crit_modifier = options[:use_ice_shards] ? 2.0 : 1.5
#   combat_mana_regen_factor = 0.0
#   total_damage_factor = 1.0
#   damage_per_cast = options[:damage_per_cast]
#   base_cast_time = options[:base_cast_time]
#   modified_cast_time = base_cast_time
#   base_mana_per_cast = options[:base_mana_per_cast]
#   modified_mana_per_cast = base_mana_per_cast
#   use_mana_pots = options[:use_mana_pots]
#   use_mana_runes = options[:use_mana_runes]
#   use_mana_gems = options[:use_mana_gems]
#   use_evocate = options[:use_evocate]
#   mana_from_pot = 1200.0 # 1800 -- major, 1200 - superior, 800 -- greater
#   mana_from_rune = 1200.0
#   mana_from_mana_ruby = 1100.0
#   mana_from_mana_citrine = 850.0
#   #consumables
#   use_nightfin_soup = options[:use_nightfin_soup]
#   use_frost_power_elixir = options[:use_frost_power_elixir]
#   use_greater_arcane_elixir = options[:use_greater_arcane_elixir]
#   use_arcane_elixir = options[:use_arcane_elixir]
#   #buffs
#   use_nightfall = options[:use_nightfall]
#   use_moonkin_form = options[:use_moonkin_form]
#   use_arcane_intellect = options[:use_arcane_intellect]
#   use_mage_armor = options[:use_mage_armor]
#   use_spirit_buff = options[:use_spirit_buff]
#   # abilities
#   use_ice_shards = options[:use_ice_shards] # crit modifier = 2.0
#   use_piercing_ice = options[:use_piercing_ice] # 6% extra dmg to frost
#   use_arcane_instability = options[:use_arcane_instability] # 3% increased spell dmg, 3% increased spell crit chance
#   use_arcane_power = options[:use_arcane_power] # spells deal 30% more dmg, cost 30% more mana, 15s duration, 180s cd
#   use_arcane_mind = options[:use_arcane_mind] # 10% more max mana
#   use_arcane_meditation = options[:use_arcane_meditation] # 15% mana regen while casting
#   use_presence_of_mind = options[:use_presence_of_mind] # next spell cast becomes instant cast, 10s duration, 180s cd
#   use_winters_chill = options[:use_winters_chill] # 2% more spell crit for frost spells, max 5 stacks, 15s duration (10% crit total)
#   use_frost_channeling = options[:use_frost_channeling] # 15% reduced mana cost for frost spells
#   use_improved_frostbolt = options[:use_improved_frostbolt] # reduces cast time of frost bolt by 0.5s
#   use_arcane_concentration = options[:use_arcane_concentration] # 10% chance upon hitting an enemy with a spell that the next spell cast will cost 0%
#   # ability flags
#   arcane_power_active = false
#   presence_of_mind_active = false

#   current_time = 0
#   last_spell_cast_time = 0.0
#   last_pot_used_time = -120.0
#   last_rune_used_time = -120.0
#   last_gem_used_time = -120.0
#   last_evocate_used_time = -480.0
#   last_arcane_power_used_time = -180.0
#   last_presence_of_mind_used_time = -180.0
#   num_mana_pots = options[:num_mana_pots]
#   num_mana_runes = options[:num_mana_runes]
#   total_mana_spent = 0
#   total_damage_done = 0
#   in_combat_ticks = 0
#   out_of_combat_ticks = 0

#   if (options[:use_arcane_meditation])
#     combat_mana_regen_factor += 0.15
#   end

#   if (options[:use_mage_armor])
#     combat_mana_regen_factor += 0.30
#   end

#   if (options[:use_nightfall])
#     total_damage_factor *= 1.15
#   end

#   if (options[:use_arcane_instability])
#     total_damage_factor *= 1.03
#     modified_crit_chance += 0.03
#   end

#   if (options[:use_piercing_ice])
#     total_damage_factor *= 1.06
#   end

#   if (options[:use_nightfin_soup])
#     mp5 += 8.0
#   end

#   if (options[:use_moonkin_form])
#     modified_crit_chance += 0.03
#   end

#   if (options[:use_winters_chill])
#     modified_crit_chance += 0.10
#   end

#   if (options[:use_greater_arcane_elixir])
#     plus_damage += 35.0
#   end

#   if (options[:use_greater_arcane_elixir])
#     plus_damage += 20.0
#   end

#   if (options[:use_frost_power_elixir])
#     plus_damage += 15.0
#   end

#   if (options[:use_arcane_intellect])
#     intelligence += 31.0
#     mana_factor = options[:use_arcane_mind] ? 1.15 : 1.0
#     base_mana += ((15.0 * 31.0) * mana_factor).round
#   end

#   if (options[:use_spirit_buff])
#     spirit += 40.0
#   end

#   if (options[:use_improved_frostbolt])
#     modified_cast_time -= 0.5
#   end

#   if (options[:use_frost_channeling])
#     modified_mana_per_cast = (modified_mana_per_cast * 0.85).round
#   end

#   if (options[:use_arcane_concentration])
#     modified_mana_per_cast = (modified_mana_per_cast * 0.90).round
#   end

#   current_mana = base_mana
#   total_mana_gained = current_mana
#   saved_modified_cast_time = modified_cast_time
#   msg = options[:msg]

#   puts "========================================================================================="
#   puts "starting mana: #{current_mana}" if show_debugging
#   puts "crit_chance: #{modified_crit_chance}" if show_debugging
#   puts "modified_mana_per_cast: #{modified_mana_per_cast}" if show_debugging

#   while (current_time < fight_duration) do
#     if (current_time >= last_arcane_power_used_time + 180 && arcane_power_active == false)
#       arcane_power_active = true
#       last_arcane_power_used_time = current_time
#       total_damage_factor *= 1.30
#       modified_mana_per_cast = (modified_mana_per_cast * 1.30).round
#       puts "arcane power now active, damage and mana cost increased by 30%" if show_debugging
#     end

#     if (current_time - last_arcane_power_used_time >= 15.0 && arcane_power_active == true)
#       arcane_power_active = false
#       total_damage_factor /= 1.30
#       modified_mana_per_cast = (modified_mana_per_cast / 1.30).round
#       puts "arcane power now inactive, damage and mana cost decreased by 30%" if show_debugging
#     end

#     if (current_time >= last_presence_of_mind_used_time + 180 && presence_of_mind_active == false)
#       presence_of_mind_active = true
#       last_presence_of_mind_used_time = current_time
#       saved_modified_cast_time = modified_cast_time
#       modified_cast_time = 1.5
#       puts "presence of mind now active, cast time changed to instant cast (1.5s)" if show_debugging
#     end

#     if (current_time - last_presence_of_mind_used_time >= 1.5 && presence_of_mind_active == true)
#       presence_of_mind_active = false
#       modified_cast_time = saved_modified_cast_time
#       puts "presence of mind now inactive, cast time changed to regular cast time (#{saved_modified_cast_time}s)" if show_debugging
#     end

#     if ((current_time >= last_evocate_used_time + 480) && (current_time - last_spell_cast_time >= 5.0))
#       last_evocate_used_time = current_time
#       puts "used evocate at time: #{current_time}, current_mana: #{current_mana}" if show_debugging

#       16.times do
#         if (current_time - last_spell_cast_time % 2.0 == 0)
#           mana_gain = (15.0 * (((mp5 / 5.0) * 2.0) + 13 + (spirit / 4.0))).round
#           puts "**evocating**, current_time: #{current_time}, mana gained this tick: #{mana_gain}" if show_debugging
#           current_mana += mana_gain
#           total_mana_gained += mana_gain
#         end

#         current_time += 0.5
#       end
#     end

#     if (current_mana <= (base_mana - mana_from_pot) && use_mana_pots == true && num_mana_pots >= 1 && current_time >= last_pot_used_time + 120)
#       current_mana += mana_from_pot
#       total_mana_gained += mana_from_pot
#       num_mana_pots -= 1
#       last_pot_used_time = current_time
#       puts "used a mana pot at time: #{current_time}, mana gained: #{mana_from_pot}" if show_debugging
#     end

#     if (current_mana <= (base_mana - mana_from_rune) && use_mana_runes == true && num_mana_runes >= 1 && current_time >= last_rune_used_time + 120)
#       current_mana += mana_from_rune
#       total_mana_gained += mana_from_rune
#       num_mana_runes -= 1
#       last_rune_used_time = current_time
#       puts "used a mana rune at time: #{current_time}, mana gained: #{mana_from_rune}" if show_debugging
#     end

#     if (current_mana <= (base_mana - mana_from_mana_ruby) && use_mana_gems == true && current_time >= last_gem_used_time + 120)
#       current_mana += mana_from_mana_ruby
#       total_mana_gained += mana_from_mana_ruby
#       last_gem_used_time = current_time
#       puts "used a mana ruby at time: #{current_time}, mana gained: #{mana_from_mana_ruby}" if show_debugging
#     end

#     if (current_mana <= (base_mana - mana_from_mana_citrine) && use_mana_gems == true && current_time >= last_gem_used_time + 120)
#       current_mana += mana_from_mana_citrine
#       total_mana_gained += mana_from_mana_citrine
#       last_gem_used_time = current_time
#       puts "used a mana citrine at time: #{current_time}, mana gained: #{mana_from_mana_citrine}" if show_debugging
#     end

#     if (current_mana >= modified_mana_per_cast)
#       current_mana -= modified_mana_per_cast
#       total_mana_spent += modified_mana_per_cast
#       modified_damage = (damage_per_cast + (plus_damage * base_cast_time / 3.5))
#       puts "modified_damage: #{modified_damage}, total_damage_factor: #{total_damage_factor}, damage_per_cast: #{damage_per_cast}, modified_cast_time: #{modified_cast_time}, plus_damage: #{plus_damage}" if show_debugging
#       damage_done_this_cast = (((modified_damage * modified_crit_chance * crit_modifier) + ((1 - modified_crit_chance) * modified_damage)) * total_damage_factor * modified_hit_chance).round
#       total_damage_done += damage_done_this_cast
#       puts "started casting at #{current_time}s, finished casting at #{current_time + modified_cast_time}s, dealt #{damage_done_this_cast} damage, spent #{modified_mana_per_cast} mana to cast, total_damage_done this combat: #{total_damage_done}" if show_debugging

#       while_casting_mana_regen = (((mp5 / 5.0) * modified_cast_time) + ((13 + (spirit / 4)) * combat_mana_regen_factor * modified_cast_time * 0.5)).round
#       current_mana += while_casting_mana_regen
#       total_mana_gained += while_casting_mana_regen
#       in_combat_ticks += (modified_cast_time / 2.0)
#       current_time += modified_cast_time
#       last_spell_cast_time = current_time
#       puts "total number of in-combat mana regen ticks: #{in_combat_ticks}" if show_combat_ticks
#     else
#       current_time += 1
      
#       if (((current_time - last_spell_cast_time) % 2 == 0) && (current_time - last_spell_cast_time) < 5)
#         in_combat_mana_regen = (((mp5 / 5.0) * 2.0) + (13 + (spirit / 4)) * combat_mana_regen_factor).round
#         total_mana_gained += in_combat_mana_regen
#         in_combat_ticks += 1 
#         puts "total number of in-combat mana regen ticks: #{in_combat_ticks}" if show_combat_ticks
#       end

#       if (((current_time - last_spell_cast_time) % 2 == 0) && (current_time - last_spell_cast_time) >= 5)
#         out_of_combat_mana_regen = (((mp5 / 5.0) * 2.0) + (13 + (spirit / 4))).round
#         current_mana += out_of_combat_mana_regen
#         total_mana_gained += out_of_combat_mana_regen
#         out_of_combat_ticks += 1
#         puts "total number of out-of-combat mana regen ticks: #{out_of_combat_ticks}" if show_combat_ticks
#       end
#     end

#     puts "total_damage_done: #{total_damage_done} current_mana: #{current_mana} current_time: #{current_time}" if show_debugging
#   end

#   total_damage_done = total_damage_done.round

#   actual_damage_done = total_damage_done
#   estimated_damage_done = total_damage_done
#   estimated_damage_done += ((total_damage_done / total_mana_spent) * current_mana).round

#   efficiency = (actual_damage_done/total_mana_spent).round(3)

#   puts "------------------------------------------"
#   puts "#{msg} total in_combat_ticks: #{in_combat_ticks} total out_of_combat_ticks: #{out_of_combat_ticks}" if show_combat_ticks
#   puts "actual_damage_done: #{actual_damage_done} estimated_damage_done: #{estimated_damage_done} total_mana_gained: #{total_mana_gained} current_mana: #{current_mana} total_mana_spent: #{total_mana_spent} current_time: #{current_time} efficiency: #{efficiency}"

#   results = {
#     :actual_damage_done => actual_damage_done,
#     :estimated_damage_done => estimated_damage_done,
#     :total_mana_spent => total_mana_spent,
#     :total_mana_gained => total_mana_gained,
#     :current_mana => current_mana,
#     :current_time => current_time,
#     :efficiency => efficiency,
#   }

#   return results
# end

# base_options = {
#   :base_mana => 6119.0,
#   :intelligence => 302.0,
#   :spirit => 150.0,
#   :plus_damage => 471.0,
#   :mp5 => 4.0,
#   :crit_chance_from_gear => 0.05,
#   :hit_chance_from_gear => 0.04,
#   :use_mana_pots => false,
#   :use_mana_runes => false,
#   :use_mana_gems => false,
#   :num_mana_pots => 5.0,
#   :num_mana_runes => 0.0,
#   :use_ice_shards => true,
#   :use_piercing_ice => true,
#   :use_arcane_instability => true,
#   :use_arcane_power => true,
#   :use_arcane_mind => true,
#   :use_arcane_meditation => true,
#   :use_presence_of_mind => true,
#   :use_winters_chill => true,
#   :use_frost_channeling => true,
#   :use_improved_frostbolt => true,
#   :use_arcane_concentration => true,
#   :use_nightfin_soup => true,
#   :use_frost_power_elixir => true,
#   :use_greater_arcane_elixir => true,
#   :use_arcane_elixir => false,
#   :use_nightfall => false,
#   :use_moonkin_form => true,
#   :use_arcane_intellect => true,
#   :use_spirit_buff => true,
#   :use_mage_armor => true,
#   :use_evocate => true,
#   :msg => "",
# }

# spell_and_fight_options = {
#   :fight_duration => 60.0,
#   :damage_per_cast => 457.5,
#   :base_cast_time => 3.0,
#   :base_mana_per_cast => 260.0,
# }

# solo_comparison = true

# stats_to_compare = {
#   :intelligence => 10.0,
#   :spirit => 10.0,
#   :mp5 => 10.0,
#   :plus_damage => 10.0,
#   :hit_chance_from_gear => 0.01,
#   :crit_chance_from_gear => 0.01,
# }

# spell_to_compare_description = "rank10 frostbolt"
# options_comparison_description = "full consumes, no world buffs"

# if (solo_comparison)
#   idx = 1
#   default_description = "#{spell_to_compare_description}, #{spell_and_fight_options[:fight_duration]}sec fight, #{options_comparison_description}"

#   options = base_options.merge(spell_and_fight_options)

#   results = []
#   options[:msg] = "BASE GEAR SET, #{default_description}"
#   results << total_damage(options)

#   stats_to_compare.each do |key,value|
#     options = base_options.merge(spell_and_fight_options)

#     options[key.to_sym] = base_options[key.to_sym] + value
#     options[:base_mana] = (base_options[:base_mana] + (16.5 * (options[:intelligence] - base_options[:intelligence]))).round if key.to_s == "intelligence"
#     if (key.to_s == "hit_chance_from_gear" || key.to_s == "crit_chance_from_gear")
#       desc_key = key.to_s == "hit_chance_from_gear" ? "hit" : "crit"
#       options[:msg] = "BASE GEAR SET with an extra +1#{desc_key}, #{default_description}"
#     else
#       options[:msg] = "BASE GEAR SET with an extra +10#{key}, #{default_description}"
#     end
    
#     results << total_damage(options)

#     puts "========================================================================================="
#     puts "========================================================================================="

#     if (key.to_s == "hit_chance_from_gear" || key.to_s == "crit_chance_from_gear")
#       desc_key = key.to_s == "hit_chance_from_gear" ? "hit" : "crit"
#       puts "+1#{desc_key} is worth: #{(results[idx][:actual_damage_done] - results[0][:actual_damage_done])} actual extra damage done and #{(results[idx][:estimated_damage_done] - results[0][:estimated_damage_done])} estimated extra damage done"
#     else
#       puts "+1#{key} is worth: #{(results[idx][:actual_damage_done] - results[0][:actual_damage_done]) / 10.0} actual extra damage done and #{(results[idx][:estimated_damage_done] - results[0][:estimated_damage_done]) / 10.0} estimated extra damage done"
#     end

#     puts "========================================================================================="
#     puts "========================================================================================="

#     idx += 1
#   end
# else
# # add code for comparing two sets of gear
# end








# options = base_options.merge(spell_and_fight_options)

# results = []

# stat_to_compare = "1spirit"
# options[:spirit] = base_options[:spirit] + 10.0
# options[:msg] = "+10 #{stat_to_compare}, rank10 frostbolt, 1 minute fight, no world buffs"
# results << total_damage(options)

# puts "========================================================================================="
# puts "========================================================================================="

# puts "#{stat_to_compare} is worth: #{(results[1][:actual_damage_done] - results[0][:actual_damage_done]) / 10.0} actual extra damage done and #{(results[1][:estimated_damage_done] - results[0][:estimated_damage_done]) / 10.0} estimated extra damage done"

# puts "========================================================================================="
# puts "========================================================================================="

# options = base_options.merge(spell_and_fight_options)

# results = []

# stat_to_compare = "1 +damage"
# options[:plus_damage] = base_options[:plus_damage] + 10.0
# options[:msg] = "+10 #{stat_to_compare}, rank10 frostbolt, 1 minute fight, no world buffs"
# results << total_damage(options)

# puts "========================================================================================="
# puts "========================================================================================="

# puts "1#{stat_to_compare} is worth: #{(results[1][:actual_damage_done] - results[0][:actual_damage_done]) / 10.0} actual extra damage done and #{(results[1][:estimated_damage_done] - results[0][:estimated_damage_done]) / 10.0} estimated extra damage done"

# puts "========================================================================================="
# puts "========================================================================================="

# options[:mp5] = base_options[:mp5] + 10.0
# options[:hit_chance_from_gear] = base_options[:hit_chance_from_gear] + 0.01
# options[:crit_chance_from_gear] = base_options[:crit_chance_from_gear] + 0.01
