class ManaregenEvent
  attr_accessor :scheduled_time, :activate, :display, :avg_amount, :cooldown, :cooldown_display
  def initialize(options)
    @scheduled_time = options[:scheduled_time]
    @activate = options[:activate]
    @display = options[:display]
    @avg_amount = options[:avg_amount]
    @cooldown = options[:cooldown]
    @cooldown_display = options[:cooldown_display]
  end
end