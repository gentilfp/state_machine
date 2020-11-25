require "state_machine/version"

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

  def transit(event, from, to)
    if @events[event][current_state] == to
      @current_state = to
    else
      raise 'invalid transition'
    end
  end

  def define_transition_methods
    events.each do |event, transitions|
      transitions.keys.each do |from|
        define_singleton_method("#{event}!") do
          transit(event, from, transitions[from])
        end
      end
    end
  end

  module ClassMethods
    def state(*args)
      name, options = args[0], args[1] || {}

      @initial_state = name if options[:initial]

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
      from, to = options[:from], options[:to]

      @events ||= {}
      @events[@current_event] ||= {}

      [from].flatten.each do |from_state|
        @events[@current_event][from_state] = to
      end
    end
  end
end
