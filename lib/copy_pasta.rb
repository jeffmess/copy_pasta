# frozen_string_literal: true

require 'copy_pasta/version'
require 'copy_pasta/error'
require 'copy_pasta/builder'
require 'copy_pasta/builder/exclude_attr'
require 'copy_pasta/builder/merge_options'
require 'copy_pasta/builder/insert'
require 'copy_pasta/builder/update_self_assoc'

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
    builder.instance_eval(&block)
    builder.validate
    builder.invoke!
  end
end
