class Simulation
  def initialize(options)
    @clock = Clock.new(options[:stop_time])
    @player = Player.new(options[:player_options])
    @modifier_tracker = ModifierTracker.new(options[:modifier_options])
    @scheduler = Scheduler.new({:clock => @clock, :modifier_tracker => @modifier_tracker, :player => @player})
  end

  def run_simulation
    while @clock.current_time <= @clock.stop_time
      @scheduler.schedule.select {|_, event_time| event_time == @clock.current_time }.each do |event, event_time|

        @scheduler.set_event_to_finished(event)
      end

      @clock.increment_current_time
    end
  end
end