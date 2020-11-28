module StateMachine
  class Machine
    attr_reader :states, :events, :callbacks, :current_state

    def initialize(initial_state:, events: {}, callbacks: {})
      @current_state = initial_state or raise NoInitialStateFound
      @events = events
      @states = extract_states_from_events
      @callbacks = callbacks
    end

    def transit(state)
      @current_state = state
    end

    private

    def extract_states_from_events
      @events.keys.flat_map { |event| events[event].keys }.uniq
    end
  end
end
