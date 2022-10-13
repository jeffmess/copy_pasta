# frozen_string_literal: true

require 'copy_pasta/version'

# Copy data between objects swiftly
module CopyPasta
  # @example
  #   require 'copypasta'
  #
  #   CopyPasta.build do
  #     from from_board
  #     to   Board.find(2) # nil will create a new board.
  #     tables %i[lists comments activities]
  #
  #     on :comments, data: from_board.lists.flat_map(&:comments)
  #   end
  #
  # @param block [Block]
  # @return [Hash<table_name, Hash<from_id, to_id>>]
  # @api public
  def self.build(&block)
    builder = Builder.new
    builder.instace_eval(&block)
    builder.invoke
  end
end
