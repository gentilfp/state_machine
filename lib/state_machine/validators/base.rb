module StateMachine
  module Validators
    class Base
      attr_reader :state_machine, :event, :transition, :obj

      def initialize(state_machine, event: nil, transition: nil, obj: nil)
        @state_machine = state_machine
        @event = event
        @transition = transition
        @obj = obj
      end

      def valid?
        raise 'Not implemented'
      end

      def fail!
        raise 'Not implemented'
      end
    end
  end
end
