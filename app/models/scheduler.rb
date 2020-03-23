class Scheduler
  attr_accessor :schedule, :finished_events
  def initialize(options)
    @clock = options[:clock]
    @modifier_tracker = options[:modifier_tracker]
    @player = options[:player]
    
    @finished_events = {}
    @schedule = schedule
  end

  def schedule_event(event_type, time)
    options = { scheduled_time: time, name: event_type }
    # case event_type
    # when "MainHandSwingEvent"
    #   @schedule[MainHandSwingEvent.new(options)] = time
    # when "OffHandSwingEvent"
    #   @schedule[OffHandSwingEvent.new(options)] = time
    # when "TwoHandSwingEvent"
    #   @schedule[TwoHandSwingEvent.new(options)] = time
    # end
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