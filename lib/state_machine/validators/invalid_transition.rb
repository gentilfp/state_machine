module StateMachine
  module Validators
    class InvalidTransition < Base
      def valid?
        state_machine.events[event][current_state]
      end

      def fail!
        raise ::StateMachine::InvalidTransition
      end

      private

      def current_state
        state_machine.current_state
      end
    end
  end
end
