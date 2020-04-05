class ModifierTracker
  attr_accessor :arcane_power, :presence_of_mind, :talisman_ephemeral, :mind_quickening_gem, :casting, :global_cooldown, 
                :last_finished_casting, :last_mana_tick, :mana_gem_cooldown_left, :mana_pot_cooldown_left, :mana_rune_cooldown_left, 
                :archmage_robe_cooldown_left

  def initialize(options)
    @player = options[:player]
    @clock = options[:clock]
    @scheduler = options[:scheduler]
    @output_logger = options[:output_logger]

    @activated_talents = options[:activated_talents]
    @activated_items = options[:activated_items].dup
    @mana_regen = options[:mana_regen]

    # @arcane_power = false
    # @presence_of_mind = false
    @presence_of_mind_saved_casting_time = 0.0
    # @talisman_ephemeral = false
    # @mind_quickening_gem = false

    @global_cooldown = false
    @casting = false
    @last_finished_casting = -10
    @last_mana_tick = 0
    @mana_gem_cooldown_left = 0
    @mana_pot_cooldown_left = 0
    @mana_rune_cooldown_left = 0
    @archmage_robe_cooldown_left = 0
    @mana_ruby_used = false
    @mana_citrine_used = false
    @mana_jade_used = false
    # puts ">>>>>>>>>>>>>>> @activated_items = #{@activated_items}"
  end

  def activate_talents_or_items
    @activated_items.keys.each do |item|
      # puts "TESTING activate_talents_or_items, item: #{item}, eval: #{eval("@#{item}")}"
      cooldown = @activated_items[item][:cooldown]
      last_used = @activated_items[item][:last_used]

      # puts "TESTING activate_talents_or_items A, last_used.nil?: #{last_used.nil?}"
      # puts "TESTING activate_talents_or_items A1, last_used?: #{last_used}"
      # puts "TESTING activate_talents_or_items B, @clock: #{@clock.nil?}"
      # puts "TESTING activate_talents_or_items B1, @clock: #{@clock.current_time}"

      if ((last_used.nil? || (@clock.current_time - last_used >= cooldown)) && !eval("@#{item}"))
        # puts "TESTING activate_talents_or_items, IF WAS TRUE"
        duration = @activated_items[item][:duration]

        if (duration.nil?)
          @scheduler.schedule_event(ActivatedEvent.new({:scheduled_time => @clock.current_time, :activate => true, :method => "#{item}_activated"}))
          @scheduler.schedule_event(ActivatedEvent.new({:scheduled_time => (@clock.current_time + 1.5).round(2), :activate => false, :method => "#{item}_activated"}))
        else
          @scheduler.schedule_event(ActivatedEvent.new({:scheduled_time => @clock.current_time, :activate => true, :method => "#{item}_activated"}))
          @scheduler.schedule_event(ActivatedEvent.new({:scheduled_time => (@clock.current_time + duration).round(2), :activate => false, :method => "#{item}_activated"}))
        end
      else
        # puts "TESTING activate_talents_or_items, IF WAS FALSE"
      end
    end

    @activated_talents.keys.each do |talent|
      cooldown = @activated_talents[talent][:cooldown]
      last_used = @activated_talents[talent][:last_used]

      if ((last_used.nil? || (@clock.current_time - last_used >= cooldown)) && !eval("@#{talent}"))
        duration = @activated_talents[talent][:duration]

        if (duration.nil?)
          @scheduler.schedule_event(ActivatedEvent.new({:scheduled_time => @clock.current_time, :activate => true, :method => "#{talent}_activated"}))
          @scheduler.schedule_event(ActivatedEvent.new({:scheduled_time => (@clock.current_time + 1.50).round(2), :activate => false, :method => "#{talent}_activated"}))
        else
          @scheduler.schedule_event(ActivatedEvent.new({:scheduled_time => @clock.current_time, :activate => true, :method => "#{talent}_activated"}))
          @scheduler.schedule_event(ActivatedEvent.new({:scheduled_time => (@clock.current_time + duration).round(2), :activate => false, :method => "#{talent}_activated"}))
        end
      end
    end
  end

  def activate_mana_regen_if_needed(max_mana, current_mana)
    mana_gained = 0

    mana_regen_items = @mana_regen.deep_dup

    mana_regen_items.delete(:mana_ruby) if @mana_ruby_used
    mana_regen_items.delete(:mana_citrine) if @mana_citrine_used
    mana_regen_items.delete(:mana_jade) if @mana_jade_used

    mana_regen_items.each do |mana_regen_item, mana_regen_item_options|
      #TODO refactor dynamically / dry out code
      if (max_mana - current_mana > mana_regen_item_options[:avg_amount])
        case mana_regen_item_options[:cooldown_type]
        when :gem
          if @mana_gem_cooldown_left == 0
            @mana_ruby_used = true if mana_regen_item == :mana_ruby
            @mana_citrine_used = true if mana_regen_item == :mana_citrine
            @mana_jade_used = true if mana_regen_item == :mana_jade

            @mana_gem_cooldown_left = mana_regen_item_options[:cooldown]
            mana_gained = mana_regen_item_options[:avg_amount]
            current_mana += mana_gained
            @scheduler.schedule_event(ManaregenEvent.new({:scheduled_time => @clock.current_time, :activate => true, :cooldown_display => mana_regen_item_options[:cooldown_display], :display => mana_regen_item_options[:display], :avg_amount => mana_regen_item_options[:avg_amount], :cooldown => mana_regen_item_options[:cooldown]}))
            @scheduler.schedule_event(ManaregenEvent.new({:scheduled_time => (@clock.current_time + mana_regen_item_options[:cooldown]).round(4), :activate => false, :cooldown_display => mana_regen_item_options[:cooldown_display], :display => mana_regen_item_options[:display], :avg_amount => mana_regen_item_options[:avg_amount], :cooldown => mana_regen_item_options[:cooldown]}))
          end
        when :pot
          if @mana_pot_cooldown_left == 0
            @mana_pot_cooldown_left = mana_regen_item_options[:cooldown]
            mana_gained = mana_regen_item_options[:avg_amount]
            current_mana += mana_gained
            @scheduler.schedule_event(ManaregenEvent.new({:scheduled_time => @clock.current_time, :activate => true, :cooldown_display => mana_regen_item_options[:cooldown_display], :display => mana_regen_item_options[:display], :avg_amount => mana_regen_item_options[:avg_amount], :cooldown => mana_regen_item_options[:cooldown]}))
            @scheduler.schedule_event(ManaregenEvent.new({:scheduled_time => (@clock.current_time + mana_regen_item_options[:cooldown]).round(4), :activate => false, :cooldown_display => mana_regen_item_options[:cooldown_display], :display => mana_regen_item_options[:display], :avg_amount => mana_regen_item_options[:avg_amount], :cooldown => mana_regen_item_options[:cooldown]}))
          end
        when :rune
          if @mana_rune_cooldown_left == 0
            @mana_rune_cooldown_left = mana_regen_item_options[:cooldown]
            mana_gained = mana_regen_item_options[:avg_amount]
            current_mana += mana_gained
            @scheduler.schedule_event(ManaregenEvent.new({:scheduled_time => @clock.current_time, :activate => true, :cooldown_display => mana_regen_item_options[:cooldown_display], :display => mana_regen_item_options[:display], :avg_amount => mana_regen_item_options[:avg_amount], :cooldown => mana_regen_item_options[:cooldown]}))
            @scheduler.schedule_event(ManaregenEvent.new({:scheduled_time => (@clock.current_time + mana_regen_item_options[:cooldown]).round(4), :activate => false, :cooldown_display => mana_regen_item_options[:cooldown_display], :display => mana_regen_item_options[:display], :avg_amount => mana_regen_item_options[:avg_amount], :cooldown => mana_regen_item_options[:cooldown]}))
          end
        when :robe
          if @archmage_robe_cooldown_left == 0
            @archmage_robe_cooldown_left = mana_regen_item_options[:cooldown]
            mana_gained = mana_regen_item_options[:avg_amount]
            current_mana += mana_gained
            @scheduler.schedule_event(ManaregenEvent.new({:scheduled_time => @clock.current_time, :activate => true, :cooldown_display => mana_regen_item_options[:cooldown_display], :display => mana_regen_item_options[:display], :avg_amount => mana_regen_item_options[:avg_amount], :cooldown => mana_regen_item_options[:cooldown]}))
            @scheduler.schedule_event(ManaregenEvent.new({:scheduled_time => (@clock.current_time + mana_regen_item_options[:cooldown]).round(4), :activate => false, :cooldown_display => mana_regen_item_options[:cooldown_display], :display => mana_regen_item_options[:display], :avg_amount => mana_regen_item_options[:avg_amount], :cooldown => mana_regen_item_options[:cooldown]}))
          end
        end
      end
    end

    mana_gained
  end

  #TALENTS
  def arcane_power_activated(activated)
    if (activated)
      # @arcane_power = true
      @player.spell_damage_multiplier = (@player.spell_damage_multiplier * 1.30).round(4)
      @player.mana_cost_multiplier = (@player.mana_cost_multiplier * 1.30).round(4)
      @activated_talents[:arcane_power][:last_used] = @clock.current_time
      @output_logger.log("Arcane Power Is Now Active", "Spell Damage Multiplier increased by 30% from: #{(@player.spell_damage_multiplier / 1.30).round(4)} to: #{@player.spell_damage_multiplier};Mana Cost Multiplier increased by 30% from: #{(@player.mana_cost_multiplier / 1.30).round(4)} to: #{@player.mana_cost_multiplier}")
    else
      # @arcane_power = false
      @player.spell_damage_multiplier = (@player.spell_damage_multiplier / 1.30).round(4)
      @player.mana_cost_multiplier = (@player.mana_cost_multiplier / 1.30).round(4)
      @output_logger.log("Arcane Power Is No Longer Active", "Spell Damage Multiplier decreased by 30% from: #{(@player.spell_damage_multiplier * 1.30).round(4)} to: #{@player.spell_damage_multiplier};Mana Cost Multiplier decreased by 30% from: #{(@player.mana_cost_multiplier * 1.30).round(4)} to: #{@player.mana_cost_multiplier}")
    end
  end

  def presence_of_mind_activated(activated)
    if (activated)
      # @presence_of_mind = true
      @presence_of_mind_saved_casting_time = @player.spell_casting_time
      @player.spell_casting_time = 0
      @activated_talents[:presence_of_mind][:last_used] = @clock.current_time
      @output_logger.log("Presence of Mind Is Now Active", "Spell Casting Time decreased by #{@presence_of_mind_saved_casting_time}s from: #{@presence_of_mind_saved_casting_time}s to: 0s")
    else
      # @presence_of_mind = false
      @player.spell_casting_time = @presence_of_mind_saved_casting_time
      @output_logger.log("Presence of Mind Is No Longer Active", "Spell Casting Time increased by #{@presence_of_mind_saved_casting_time}s from: 0s to: #{@presence_of_mind_saved_casting_time}s")
    end
  end

  #ITEMS
  def talisman_ephemeral_activated(activated)
    # puts "TALISMAN EPHEMERAL CALLED, activated: #{activated}"
    if (activated)
      # @talisman_ephemeral = true
      @player.spell_damage = (@player.spell_damage + References::ACTIVATED_ITEMS[:talisman_ephemeral][:amount]).round(4)
      @activated_items[:talisman_ephemeral][:last_used] = @clock.current_time
      @output_logger.log("Talisman of Ephemeral Power Is Now Active", "Spell Damage increased by #{References::ACTIVATED_ITEMS[:talisman_ephemeral][:amount]} from: #{(@player.spell_damage - References::ACTIVATED_ITEMS[:talisman_ephemeral][:amount]).round(4)} to: #{@player.spell_damage}")
    else
      # @talisman_ephemeral = false
      @player.spell_damage = (@player.spell_damage - References::ACTIVATED_ITEMS[:talisman_ephemeral][:amount]).round(4)
      @output_logger.log("Talisman of Ephemeral Power Is No Longer Active", "Spell Damage decreased by #{References::ACTIVATED_ITEMS[:talisman_ephemeral][:amount]} from: #{(@player.spell_damage + References::ACTIVATED_ITEMS[:talisman_ephemeral][:amount]).round(4)} to: #{@player.spell_damage}")
    end
  end

  def mind_quickening_gem_activated(activated)
    if (activated)
      # @mind_quickening_gem = true
      @player.spell_casting_time_multiplier = (@player.spell_casting_time_multiplier * References::ACTIVATED_ITEMS[:mind_quickening_gem][:amount]).round(4)
      @activated_items[:mind_quickening_gem][:last_used] = @clock.current_time
      @output_logger.log("Mind Quickening Gem Is Now Active", "Spell Casting Time Multiplier decreased by 33% from: #{(@player.spell_casting_time_multiplier / References::ACTIVATED_ITEMS[:mind_quickening_gem][:amount]).round(4)} to: #{@player.spell_casting_time_multiplier}")
    else
      # @mind_quickening_gem = false
      @player.spell_casting_time_multiplier = (@player.spell_casting_time_multiplier / References::ACTIVATED_ITEMS[:mind_quickening_gem][:amount]).round(4)
      @output_logger.log("Mind Quickening Gem Is No Longer Active", "Spell Casting Time Multiplier increased by 50% from: #{(@player.spell_casting_time_multiplier * References::ACTIVATED_ITEMS[:mind_quickening_gem][:amount]).round(4)} to: #{@player.spell_casting_time_multiplier}")
    end
  end

  def global_cooldown_activated(activated)
    if (activated)
      @global_cooldown = true
      @scheduler.schedule_event(GlobalcooldownEvent.new({:scheduled_time => @clock.current_time, :activate => true, :method => :global_cooldown_activated}))
      @scheduler.schedule_event(GlobalcooldownEvent.new({:scheduled_time => (@clock.current_time + 1.50).round(4), :activate => false, :method => :global_cooldown_activated}))
    else
      @global_cooldown = false
    end
  end

  def spell_casting_activated(activated)
    if (activated)
      @casting = true
      @scheduler.schedule_event(SpellcastEvent.new({:scheduled_time => @clock.current_time, :activate => true, :method => :spell_casting_activated, :spell => @player.spell}))
      cast_time = @player.spell_casting_time * @player.spell_casting_time_multiplier
    else
      @casting = false
    end
  end

  def decrement_cooldowns
    @mana_gem_cooldown_left = (@mana_gem_cooldown_left - 0.01).round(2) if @mana_gem_cooldown_left > 0.0
    @mana_pot_cooldown_left = (@mana_pot_cooldown_left - 0.01).round(2) if @mana_pot_cooldown_left > 0.0
    @mana_rune_cooldown_left = (@mana_rune_cooldown_left - 0.01).round(2) if @mana_rune_cooldown_left > 0.0
    @archmage_robe_cooldown_left = (@archmage_robe_cooldown_left - 0.01).round(2) if @archmage_robe_cooldown_left > 0.0
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