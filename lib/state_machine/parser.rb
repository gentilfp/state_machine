module StateMachine
  module Parser
    class OnlyOneInitialStateAllowed < StandardError; end
    class InvalidStateInTransition < StandardError; end

    attr_reader :states

    def state(*args)
      name, options = args[0], args[1] || {}

      set_initial_state(name) if options[:initial]

      states << name

      self
    end

    def event(*args, &block)
      @current_event = args[0]

      yield if block_given?

      self
    end

    def transitions(*args)
      options = args[0]
      from, to, guard = options[:from], options[:to], options[:when]

      raise InvalidStateInTransition unless validate_states_in_transation(from, to)

      [from].flatten.each do |from_state|
        events[@current_event][from_state] = Transition.new(from_state, to, guard)
      end

      self
    end

    def on_enter(*args, &block)
      state_name = args.first

      callbacks[:enter_state][state_name] = Callback.new(block)

      self
    end

    def on_leave(*args, &block)
      state_name = args.first

      callbacks[:leave_state][state_name] = Callback.new(block)

      self
    end

    def on_transition(*args, &block)
      transition_name = args.first

      callbacks[:transition][transition_name] = Callback.new(block)

      self
    end

    private

    def set_initial_state(name)
      @initial_state ||= nil

      raise OnlyOneInitialStateAllowed if @initial_state

      @initial_state = name
    end

    def states
      @states ||= []
    end

    def callbacks
      @callbacks || initialize_callbacks
    end

    def events
      @events ||= {}
      @events[@current_event] ||= {}

      @events
    end

    def validate_states_in_transation(from, to)
      event_states = [from, to].flatten
      states_intersection = (states & event_states)

      return false unless event_states.all? {|s| states_intersection.include?(s)}

      true
    end

    def initialize_callbacks
      @callbacks ||= {}
      @callbacks[:enter_state] ||= {}
      @callbacks[:leave_state] ||= {}
      @callbacks[:transition] ||= {}
      @callbacks
    end
  end
end
