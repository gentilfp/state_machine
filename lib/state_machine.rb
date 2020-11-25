require "state_machine/version"
require "state_machine/transition"

module StateMachine
  class Error < StandardError; end

  def self.included(base)
    base.extend StateMachine::ClassMethods
  end

  def initialize(initial_state = nil)
    set_initial_state(initial_state)
    register_events
    define_transition_methods
  end

  def set_initial_state(initial_state)
    @current_state = initial_state || self.class.instance_variable_get(:@initial_state)
  end

  def register_events
    @events = self.class.instance_variable_get(:@events)
  end

  def events
    @events
  end

  def current_state
    @current_state
  end

  def transit(event, transition)
    raise 'InvalidTransition' if @events[event][current_state].nil?
    raise 'TransitionGuardClauseViolated' unless transition.valid_guard?(self)

    @current_state = transition.to
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
  end
end
