class Clock
  attr_accessor :current_time, :stop_time
  def initialize(stop_time)
    @stop_time = stop_time
    @current_time = 0.0
  end

  def increment_current_time
    (@current_time += 0.01).round(2)
  end

  def current_time
    @current_time.round(2)
  end
end