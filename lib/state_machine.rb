require "state_machine/version"

module StateMachine
  class Error < StandardError; end

  def self.included(base)
    base.extend StateMachine::ClassMethods
  end

  module ClassMethods
    def state(*args)
      name, options = args[0], args[1]

      define_method("#{name}?") do
        @current_state == name
      end
    end
  end
end
