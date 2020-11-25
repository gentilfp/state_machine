class Callback
  attr_reader :code_block

  def initialize(code_block = nil)
    @code_block = code_block
  end

  def call
    code_block&.call
  end
end
