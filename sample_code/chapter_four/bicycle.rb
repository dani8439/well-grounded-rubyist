class Bicycle
  attr_reader :gears, :wheels, :seats
  def initialize(gears = 1)
    # triggered initialize method, which sets the bicycle-like default values for other properties of the tandem.
    @wheels = 2
    @seats = 1
    @gears = gears
  end
end

class Tandem < Bicycle
  def initialize(gears)
    super
    # Here super provides a clean way to make a tandem almost like a bicycle. We change only what needs to be changed.
    # (the number of seats 2), and super triggers the earlier initialize method.
    @seats = 2
  end
end
