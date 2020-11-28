module StateMachine

  attr_reader :state_machine

  def self.included(base)
    base.extend StateMachine::Parser
  end

  def initialize(initial_state = nil)
    initialize_machine(initial_state)
    define_methods
  end

  def transit(event, transition)
    raise InvalidTransition if @state_machine.events[event][@state_machine.current_state].nil?
    raise TransitionGuardClauseViolated unless transition.valid_guard?(self)

    run_before_callbacks(event)

    @state_machine.transit(transition.to)

    run_after_callbacks
  end

  def can_transit?(event, transition)
    !@state_machine.events[event][@state_machine.current_state].nil? && transition.valid_guard?(self)
  end

  private

  def run_before_callbacks(event)
    @state_machine.callbacks[:leave_state][@state_machine.current_state]&.call
    @state_machine.callbacks[:transition][event]&.call
  end

  def run_after_callbacks
    @state_machine.callbacks[:enter_state][@state_machine.current_state]&.call
  end

  def initialize_machine(initial_state)
    @state_machine = Machine.new(
      events: self.class.instance_variable_get(:@events),
      callbacks: self.class.instance_variable_get(:@callbacks),
      initial_state: initial_state || self.class.instance_variable_get(:@initial_state)
    )
  end

  def define_methods
    define_state_methods
    define_event_methods
  end

  def define_state_methods
    @state_machine.states.each do |state|
      define_singleton_method("#{state}?") do
        @state_machine.current_state == state
      end
    end
  end

  def define_event_methods
    @state_machine.events.each do |event, transitions|
      transitions.each_key do |from|
        define_singleton_method("#{event}!") do
          transit(event, transitions[from])
        end

        define_singleton_method("can_#{event}?") do
          can_transit?(event, transitions[from])
        end
      end
    end
  end
end
