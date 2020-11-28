# frozen_string literal: true

RSpec.describe StateMachine::Validators::InvalidTransition do
  subject { described_class.new(state_machine, event: event) }
  let(:state_machine) { double(:state_machine, current_state: :standing, events: state_machine_events) }
  let(:event) { :run }

  describe '.valid?' do
    context 'when transition exists' do
      let(:state_machine_events) do
        {
          run: {
            standing: double(:transition)
          }
        }
      end

      it { expect(subject.valid?).to be_truthy }
    end

    context 'when event does not exist' do
      let(:state_machine_events) do
        {
          run: {
            stopped: double(:transition)
          }
        }
      end

      it { expect(subject.valid?).to be_falsey }
    end
  end

  describe 'fail!' do
    let(:state_machine_events) { nil }

    it 'raises exception' do
      expect { subject.fail! }.to raise_error(::StateMachine::InvalidTransition)
    end
  end
end
