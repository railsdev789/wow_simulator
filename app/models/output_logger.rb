class OutputLogger
  attr_accessor :output, :formatted_current_time, :totals
  def initialize(clock)
    @clock = clock
    @output = []
    @totals = {}
  end

  def log(description, string)
    @output << [formatted_current_time, description, string]
  end

  def formatted_current_time
    milliseconds = ((@clock.current_time.round(2) - @clock.current_time.truncate).round(2) * 100).to_i
    seconds = ((@clock.current_time - (milliseconds / 100.0)) % 60).to_i
    minutes = (@clock.current_time / 60).truncate.to_i

    "#{[minutes, seconds].map { |t| t.to_s.rjust(2,'0') }.join(':')}.#{milliseconds.to_s.rjust(2,'0')}"
  end
end