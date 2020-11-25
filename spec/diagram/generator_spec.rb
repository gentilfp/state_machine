require 'spec_helper'
require 'diagram/generator'

RSpec.describe Diagram::Generator do
  subject { described_class.new(obj, output).call }

  let(:output) { './tmp' }
  let(:graphviz_mock) { double(:graphviz) }
  let(:obj) do
    double(:class_with_states,
           states: %i[standing walking running],
           events: {
             walk: { standing: double(:transition, from: :standing, to: :walking) },
             run: { walking: double(:transition, from: :walking, to: :running) },
             hold: { running: double(:transition, from: :running, to: :standing) }
           })
  end

  context 'generating a diagram' do
    it 'add nodes and edges and generate a diagram' do
      expect(GraphViz).to receive(:new).with(:G, type: :digraph) { graphviz_mock }

      expect(graphviz_mock).to receive(:add_nodes).exactly(3).times { nil }
      expect(graphviz_mock).to receive(:add_edges).exactly(3).times { nil }

      expect(graphviz_mock).to receive(:output).with(png: output) { nil }

      subject
    end
  end
end
