# frozen_string_literal: true

module StateMachine
  module Parser
    class OnlyOneInitialStateAllowed < StandardError; end
    class InvalidStateInTransition < StandardError; end

    def state(*args)
      name = args[0]
      options = args[1] || {}

      initial_state(name) if options[:initial]

      states << name

      self
    end

    def event(*args)
      @current_event = args[0]

      yield if block_given?

      self
    end

    def transitions(*args)
      options = args[0]
      from = options[:from]
      to = options[:to]
      guard = options[:when]

      raise InvalidStateInTransition unless validate_states_in_transation(from, to)

      [from].flatten.each do |from_state|
        events[@current_event][from_state] = Transition.new(from: from_state, to: to, guard: guard)
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

    def initial_state(name)
      @initial_state ||= nil

      raise OnlyOneInitialStateAllowed if @initial_state

      @initial_state = name
    end

    def states
      @states ||= []
    end

    def callbacks
      @callbacks ||= initialize_callbacks
    end

    def events
      @events ||= {}
      @events[@current_event] ||= {}

      @events
    end

    def validate_states_in_transation(from, to)
      event_states = [from, to].flatten
      states_intersection = (states & event_states)

      return false unless event_states.all? { |s| states_intersection.include?(s) }

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
