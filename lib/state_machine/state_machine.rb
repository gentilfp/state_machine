module StateMachine
  attr_reader :state_machine

  def self.included(base)
    base.extend StateMachine::Parser
  end

  def initialize(initial_state = nil)
    @state_machine = Machine.new(
      states: self.class.instance_variable_get(:@states),
      events: self.class.instance_variable_get(:@events),
      callbacks: self.class.instance_variable_get(:@callbacks),
      initial_state: initial_state || self.class.instance_variable_get(:@initial_state)
    )

    MethodDefiner.new(@state_machine, self.class).define_methods
  end

  def transit(event, transition)
    validate_transition(event, transition)
    run_before_callbacks(event)

    state_machine.transit(transition.to)

    run_after_callbacks
  end

  def can_transit?(event, transition)
    validators(event, transition).each { |validator| return false unless validator.valid? }

    true
  end

  private

  def validate_transition(event, transition)
    validators(event, transition).each { |validator| validator.fail! unless validator.valid? }
  end

  def validators(event, transition)
    [Validators::InvalidTransition,
     Validators::TransitionGuardClauseViolated].flat_map do |validator_klass|
      validator_klass.new(@state_machine, event: event, transition: transition, obj: self)
    end
  end

  def run_before_callbacks(event)
    state_machine.callbacks[:leave_state][@state_machine.current_state]&.call
    state_machine.callbacks[:transition][event]&.call
  end

  def run_after_callbacks
    state_machine.callbacks[:enter_state][@state_machine.current_state]&.call
  end
end
