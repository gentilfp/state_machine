# frozen_string literal: true

RSpec.describe StateMachine::Validators::Base do
  subject { described_class.new(state_machine, event: event, transition: transition, obj: obj) }
  let(:state_machine) { double(:state_machine) }
  let(:event) { double(:event) }
  let(:transition) { double(:transition) }
  let(:obj) { double(:obj) }

  context 'attributes' do
    it { expect(subject.state_machine).to eq state_machine }
    it { expect(subject.event).to eq event }
    it { expect(subject.transition).to eq transition }
    it { expect(subject.obj).to eq obj }
  end

  describe '.valid?' do
    it { expect { subject.valid? }.to raise_error('Not implemented') }
  end

  describe '.fail!' do
    it { expect { subject.fail! }.to raise_error('Not implemented') }
  end
end
