# frozen_string_literal: true

RSpec.describe StateMachine::Machine do
  context 'attributes' do
    subject { described_class.new(args) }
    let(:args) { { events: events, callbacks: callbacks, initial_state: initial_state } }
    let(:states) { %i[pending stopped] }
    let(:events) do
      {
        run: { pending: double(:transition) },
        stop: { stopped: double(:transition) }
      }
    end
    let(:callbacks) { double(:callbacks) }
    let(:initial_state) { :pending }

    it { expect(subject.events).to eq events }
    it { expect(subject.callbacks).to eq callbacks }
    it { expect(subject.current_state).to eq initial_state }
  end

  describe '.transit' do
    subject { described_class.new(initial_state: :foo) }
    before { subject.transit(:bar) }

    it { expect(subject.current_state).to eq :bar }
  end
end
