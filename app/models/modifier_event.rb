class ModifierEvent < DurationEvent
  attr_accessor :active, :activate, :deactivate
  def initialize(options)
    super
    @active = options[:active]
    @attribute_to_modify = options[:attribute_to_modify]
    @amount = options[:amount]
  end

  def activate
    @active = true
  end

  def deactivate
    @active = false
  end
end