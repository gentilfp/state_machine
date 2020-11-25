require "state_machine/version"

module StateMachine
  class Error < StandardError; end

  def self.included(base)
    base.extend StateMachine::ClassMethods
  end

  def initialize(initial_state = nil)
    @initial_state = initial_state
  end

  def current_state
    @initial_state || self.class.instance_variable_get(:@initial_state)
  end

  module ClassMethods
    def state(*args)
      name, options = args[0], args[1] || {}

      instance_variable_set(:@initial_state, name) if options[:initial]

      define_method("#{name}?") do
        current_state == name
      end
    end
  end
end
