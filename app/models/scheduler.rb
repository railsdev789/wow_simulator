class Scheduler
  attr_accessor :schedule, :finished_events
  def initialize(options)
    @clock = options[:clock]
    @player = options[:player]
    
    @finished_events = {}
    @schedule = {}
  end

  def schedule_event(event)
    puts "ENTERED SCHEDULE EVENT METHOD, event.class: #{event.class}"
    #TODO dynamic refactor / dry out code
    case (event.class.to_s)
    when "GlobalcooldownEvent"
      @schedule[event] = event.scheduled_time
    when "ActivatedEvent"
      puts "INSIDE ACTIVATED EVENT STRING"
      @schedule[event] = event.scheduled_time
    when "SpellcastEvent"
      schedule[event] = event.scheduled_time
    when "ManaregenEvent"
      schedule[event] = event.scheduled_time
    else
      puts "WHAT THE FUCK, HOW DID YOU GET HERE"
    end
  end

  def set_event_to_finished(event)
    @finished_events[event] = event.scheduled_time
    @schedule.delete(event)
  end

  # def print_schedule
  #   puts "Scheduled events: (current time is #{@clock.current_time})"
  #   @schedule.each do |event, time|
  #     puts "#{event.class.name}, #{time}"
  #   end
  # end

  # def print_finished_events
  #   puts "Finished events:"
  #   @finished_events.each do |event, time|
  #     puts "#{event.class.name}, #{time}"
  #   end
  # end
end