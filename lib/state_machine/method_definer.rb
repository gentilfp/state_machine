module StateMachine
  class MethodDefiner
    def initialize(state_machine, klass)
      @state_machine = state_machine
      @klass = klass
    end

    def define_methods
      define_state_methods
      define_event_methods
    end

    private

    def define_state_methods
      @state_machine.states.each do |state|
        @klass.send(:define_method, "#{state}?") do
          @state_machine.current_state == state
        end
      end
    end

    def define_event_methods
      @state_machine.events.each do |event, transitions|
        transitions.each_key do |from|
          @klass.send(:define_method, "#{event}!") do
            transit(event, transitions[from])
          end

          @klass.send(:define_method, "can_#{event}?") do
            can_transit?(event, transitions[from])
          end
        end
      end
    end
  end
end
