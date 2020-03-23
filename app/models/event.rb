class Event
  attr_accessor :scheduled_time, :name
  def initialize(options)
    @start_time = options[:start_time]
    @name = options[:name]
  end
end