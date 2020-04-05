class Simulation
  attr_accessor :output, :totals
  def initialize(options)
    # puts ">>>>>>>>>>>>>> ENTERED SIMULATION INITIALIZATION"
    @clock = Clock.new(options[:stop_time])
    @output_logger = OutputLogger.new(@clock)
    @player = Player.new(options[:player_options].merge({:output_logger => @output_logger}))
    @scheduler = Scheduler.new({:clock => @clock, :player => @player, :output_logger => @output_logger})
    @modifier_tracker = ModifierTracker.new(options[:modifier_options].merge({:output_logger => @output_logger, :player => @player, :clock => @clock, :scheduler => @scheduler}))
    @damage = 0
    @current_mana = @player.mana
    @max_mana = @player.mana
    @mana_gained = 0
    @mana_spent = 0
    @number_of_casts = 0
    @show_debugging = false
  end

  def run_simulation
    while @clock.current_time <= @clock.stop_time
      @modifier_tracker.last_mana_tick = @clock.current_time if @current_mana == @max_mana
      @modifier_tracker.activate_talents_or_items

      # puts "TESTING_schedule: #{@scheduler.schedule}"

      mana_cost = @player.spell_mana_cost * @player.mana_cost_multiplier

      if (!@modifier_tracker.casting && !@modifier_tracker.global_cooldown && @current_mana >= mana_cost)
        @modifier_tracker.spell_casting_activated(true)
      end

      if @current_mana < @max_mana
        mana_gained_from_regen_item = @modifier_tracker.activate_mana_regen_if_needed(@max_mana, @current_mana) 
        @current_mana += mana_gained_from_regen_item
        @mana_gained += mana_gained_from_regen_item
      end

      @scheduler.schedule.select {|_, event_time| event_time == @clock.current_time }.each do |event, event_time|
        case event.class.to_s
        when "ActivatedEvent"
          # if (event.activate)
          #   # puts "TESTING SIMULATION ACTIVATION, method: #{event.method}"
          #   @modifier_tracker.send(event.method, true)
          # else
          #   # puts "TESTING SIMULATION DE-ACTIVATION, method: #{event.method}"
          #   @modifier_tracker.send(event.method, false)
          # end
          @modifier_tracker.send(event.method, event.activate)
        when "GlobalcooldownEvent"
          if (event.activate)
            @output_logger.log("Global Cooldown Is Now Active", "Global Cooldown Active from: #{@clock.current_time}s to: #{(@clock.current_time + 1.50).round(4)}s")
          else
            @modifier_tracker.global_cooldown_activated(false)

            if (!@modifier_tracker.casting && !@modifier_tracker.global_cooldown && @current_mana >= mana_cost)
              @modifier_tracker.spell_casting_activated(true)
            end

            @output_logger.log("Global Cooldown Is No Longer Active", "Global Cooldown Is No Longer Active at: #{@clock.current_time}s")
          end
        when "ManaregenEvent"
          if (event.activate)
            @output_logger.log("Gained Mana From #{event.display}", "Used #{event.display} at: #{@clock.current_time}s on Cooldown Until: #{(@clock.current_time + event.cooldown).round(2)}s, Gained #{event.avg_amount} Mana, Current Mana: #{@current_mana}, Total Mana Gained: #{@mana_gained}")
          else
            @output_logger.log("#{event.cooldown_display} Now Off Cooldown", "#{event.cooldown_display} is Now Available to be Used Again as of: #{@clock.current_time}s")
          end
        when "SpellcastEvent"
          if (event.activate)
            @modifier_tracker.global_cooldown_activated(true)
            cast_time = (@player.spell_casting_time * @player.spell_casting_time_multiplier).round(2)
            @scheduler.schedule_event(SpellcastEvent.new({:scheduled_time => (@clock.current_time + cast_time).round(4), :activate => false, :method => :spell_casting_activated, :spell => @player.spell}))
            @output_logger.log("DEBUG", "cast_time: #{cast_time}, @player.spell_casting_time: #{@player.spell_casting_time}, @player.spell_casting_time_multiplier #{@player.spell_casting_time_multiplier}") if @show_debugging
            @output_logger.log("Began Casting #{@player.spell[:display]}", "Casting #{@player.spell[:display]} from: #{@clock.current_time}s to: #{(@clock.current_time + cast_time).round(4)}s")
          else
            @modifier_tracker.spell_casting_activated(false)
            @modifier_tracker.last_finished_casting = @clock.current_time
            avg_spell_damage_per_cast = ((@player.spell_max_damage + @player.spell_min_damage) / 2.0).round(4)
            modified_damage = (avg_spell_damage_per_cast + (@player.spell_damage * @player.spell_coefficient))
            damage_done_this_cast = (((modified_damage * @player.spell_crit_chance * @player.spell_crit_multiplier) + ((1 - @player.spell_crit_chance) * modified_damage)) * @player.spell_damage_multiplier * @player.spell_hit_chance).round
            @damage += damage_done_this_cast

            mana_cost = @player.spell_mana_cost * @player.mana_cost_multiplier
            @current_mana -= mana_cost
            @mana_spent += mana_cost
            @number_of_casts += 1
            
            if (!@modifier_tracker.casting && !@modifier_tracker.global_cooldown && @current_mana >= mana_cost)
              @modifier_tracker.spell_casting_activated(true)
            end

            @output_logger.log("Finished Casting #{@player.spell[:display]}", "Finished Casting #{@player.spell[:display]} at: #{@clock.current_time}s, Damage: #{damage_done_this_cast}, Total Damage: #{@damage}, Current Mana: #{@current_mana}, Total Mana Spent: #{@mana_spent}, Cast Number: #{@number_of_casts}")
          end
        else
          # puts "HOW THE FUCK DID YOU POSSIBLY GET HERE, ERROR"
        end

        @scheduler.set_event_to_finished(event)
      end

      if (@scheduler.schedule.select {|_, event_time| event_time == @clock.current_time }.size == 0)
        if ((@current_mana < @max_mana) && (@clock.current_time - @modifier_tracker.last_mana_tick >= 2))
          if (@clock.current_time - @modifier_tracker.last_finished_casting >= 5)
            #out of combat regen
            out_of_combat_mana_regen = ((@player.mp5 / 2.5) + ((@player.spirit / 4) + 13)).round
            @current_mana += out_of_combat_mana_regen
            @mana_gained += out_of_combat_mana_regen
            @output_logger.log("Out of Combat Mana Regen Tick", "Gained #{out_of_combat_mana_regen} Mana, Current Mana: #{@current_mana}, Total Mana Gained: #{@mana_gained}")
          else
            #in combat regen
            in_combat_mana_regen = ((@player.mp5 / 2.5) + (((@player.spirit / 4) + 13) * @player.combat_mana_regen)).round
            @current_mana += in_combat_mana_regen
            @mana_gained += in_combat_mana_regen
            @output_logger.log("In Combat Mana Regen Tick", "Gained #{in_combat_mana_regen} Mana, Current Mana: #{@current_mana}, Total Mana Gained: #{@mana_gained}")
          end
          @modifier_tracker.last_mana_tick = @clock.current_time
        end

        @modifier_tracker.decrement_cooldowns
        @clock.increment_current_time
      end
    end

    @output_logger.totals = {:total_damage => @damage, :damage_per_mana => (@damage / @mana_spent).round(4), :damage_per_cast => (@damage / @number_of_casts).round(4), :max_mana => @max_mana, :current_mana => @current_mana, 
                             :mana_gained => @mana_gained, :mana_spent => @mana_spent, :number_of_casts => @number_of_casts}


  end

  def output
    @output_logger.output
  end

  def totals
    @output_logger.totals
  end
end