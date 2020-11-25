require "state_machine/version"
require "state_machine/transition"
require "state_machine/callback"

module StateMachine
  class Error < StandardError; end

  def self.included(base)
    base.extend StateMachine::ClassMethods
  end

  def initialize(initial_state = nil)
    set_initial_state(initial_state)
    register_events
    define_transition_methods
    register_callbacks
  end

  def set_initial_state(initial_state)
    @current_state = initial_state || self.class.instance_variable_get(:@initial_state)
  end

  def register_events
    @events = self.class.instance_variable_get(:@events)
  end

  def register_callbacks
    @callbacks = self.class.instance_variable_get(:@callbacks)
  end

  def events
    @events
  end

  def callbacks
    @callbacks
  end

  def current_state
    @current_state
  end

  def transit(event, transition)
    raise 'InvalidTransition' if @events[event][current_state].nil?
    raise 'TransitionGuardClauseViolated' unless transition.valid_guard?(self)

    callbacks[:leave_state][@current_state]&.call
    callbacks[:transition][event]&.call

    @current_state = transition.to

    callbacks[:enter_state][@current_state]&.call
  end

  def can_transit?(event, transition)
    !@events[event][current_state].nil? && transition.valid_guard?(self)
  end

  def define_transition_methods
    events.each do |event, transitions|
      transitions.keys.each do |from|
        define_singleton_method("#{event}!") do
          transit(event, transitions[from])
        end

        define_singleton_method("can_#{event}?") do
          can_transit?(event, transitions[from])
        end
      end
    end
  end

  module ClassMethods
    def state(*args)
      name, options = args[0], args[1] || {}

      if options[:initial]
        raise 'OnlyOneInitialStateAllowed' if @initial_state

        @initial_state = name
      end

      @states ||= []
      @states << name

      define_method("#{name}?") do
        current_state == name
      end
    end

    def event(*args, &block)
      name = args[0]

      @current_event = name
      yield if block_given?
    end

    def transitions(*args)
      options = args[0]
      from, to, guard = options[:from], options[:to], options[:when]

      event_states = [from, to].flatten
      states_intersection = (@states & event_states)
      unless  event_states.all? {|state| states_intersection.include?(state)}
        raise 'InvalidStateInTransition'
      end

      @events ||= {}
      @events[@current_event] ||= {}

      [from].flatten.each do |from_state|
        transition = Transition.new(from_state, to, guard)
        @events[@current_event][from_state] = transition
      end
    end

    def on_enter(*args, &block)
      state_name = args[0]

      @callbacks ||= {}
      @callbacks[:enter_state] ||= {}
      @callbacks[:enter_state][state_name] = Callback.new(block)
    end

    def on_leave(*args, &block)
      state_name = args[0]

      @callbacks ||= {}
      @callbacks[:leave_state] ||= {}
      @callbacks[:leave_state][state_name] = Callback.new(block)
    end

    def on_transition(*args, &block)
      transition_name = args[0]

      @callbacks ||= {}
      @callbacks[:transition] ||= {}
      @callbacks[:transition][transition_name] = Callback.new(block)
    end
  end
end
