class Transition
  attr_reader :from, :to, :guard

  def initialize(from, to, guard = nil)
    @from = from
    @to = to
    @guard = guard
  end
end
