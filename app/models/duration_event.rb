class DurationEvent < Event
  def initialize(options)
    super
    @stop_time = options[:stop_time]
  end
end