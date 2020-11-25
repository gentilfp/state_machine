require 'spec_helper'

RSpec.describe Builder do
  context 'parsing states, events and transitions' do
    subject do
      class StateTestClass
        extend Builder

        state :pending, initial: true
        state :done
      end
    end

    let(:initial_state) { subject.instance_variable_get(:@initial_state) }
    let(:states) { subject.instance_variable_get(:@states) }

    it 'reads state config' do
      expect(initial_state).to eq :pending
      expect(states).to eq [:pending, :done]
    end
  end

  context 'events and transitions' do
    subject do
      class EventTransitionTestClass
        extend Builder

        state :pending, initial: true
        state :done

        event :run do
          transitions from: :pending, to: :done, when: -> { true }
        end
      end
    end

    let(:events) { subject.instance_variable_get(:@events) }

    it 'builds events hash' do
      expect(events).to include(:run)
      expect(events[:run]).to include(:pending)
      expect(events[:run][:pending]).to be_a Transition
    end
  end

  context 'state callbacks' do
    subject do
      class StateCallbackTestClass
        extend Builder

        state :pending, initial: true
        state :done

        on_enter :done
        on_leave :pending
      end
    end

    let(:callbacks) { subject.instance_variable_get(:@callbacks) }

    it 'builds callbacks hash' do
      expect(callbacks[:enter_state]).to include(:done)
      expect(callbacks[:leave_state]).to include(:pending)
    end
  end

  context 'transition callbacks' do
    subject do
      class TransitionCallbackTestClass
        extend Builder

        state :pending, initial: true
        state :done

        event :run do
          transitions from: :pending, to: :done, when: -> { true }
        end

        on_transition :run
      end
    end

    let(:callbacks) { subject.instance_variable_get(:@callbacks) }

    it 'builds callbacks hash' do
      expect(callbacks[:transition]).to include(:run)
    end
  end
end
