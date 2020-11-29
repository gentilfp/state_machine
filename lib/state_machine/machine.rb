module StateMachine
  class Machine
    attr_reader :states, :events, :callbacks, :current_state

    def initialize(initial_state:, states: {}, events: {}, callbacks: {})
      @current_state = initial_state or raise NoInitialStateFound
      @events = events
      @states = states
      @callbacks = callbacks
    end

    def transit(state)
      @current_state = state
    end
  end
end
