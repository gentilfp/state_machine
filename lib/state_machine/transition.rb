class Transition
  attr_reader :from, :to, :guard

  def initialize(from, to, guard = nil)
    @from = from
    @to = to
    @guard = guard
  end

  def valid_guard?(obj = nil)
    case guard
    when Symbol
      obj.send(guard)
    when Proc
      guard.call
    end
  end
end
