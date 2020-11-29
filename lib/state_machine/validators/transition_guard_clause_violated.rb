module StateMachine
  module Validators
    class TransitionGuardClauseViolated < Base
      def valid?
        transition.valid_guard?(obj)
      end

      def fail!
        raise ::StateMachine::TransitionGuardClauseViolated
      end
    end
  end
end
