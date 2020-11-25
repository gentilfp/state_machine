require 'ruby-graphviz'

module Diagram
  class Generator
    attr_reader :obj, :output, :graph, :diagram

    def initialize(obj, output)
      @obj = obj
      @output = output || "tmp/#{Time.now.to_i}_diagram.png"
      @graph = GraphViz.new(:G, type: :digraph)
      @diagram = {}
    end

    def call
      add_nodes
      add_edges

      @graph.output(png: @output)
    end

    private

    def add_nodes
      @obj.states.each do |state|
        @diagram[state] = @graph.add_nodes(state.to_s)
      end
    end

    def add_edges
      @obj.events.each_value do |events|
        events.each_value do |transition|
          @graph.add_edges(@diagram[transition.from], @diagram[transition.to])
        end
      end
    end
  end
end
