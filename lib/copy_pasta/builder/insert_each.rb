# frozen_string_literal: true

module CopyPasta
  class Builder
    # This class is responsible for iterating over a collection, inititializing and saving.
    # It is slower in perf over Insert but necessary for some use cases.
    class InsertEach
      # @param klass [ActiveRecord::Model] # class of an active record model
      # @param items [Array<JSON>] # array of json attributes for the active record model specified
      # @return [Array<Integer>] # returns an array of ids saved into the database
      # @api private
      def call(klass, items, _from_collection)
        # todo - skip validation
        #      - remove _from_collection
        #      - swap openstruct for Struct?
        #      - each_with_index might not be needed any longer
        OpenStruct.new(rows: items.each_with_index.map do |res, _idx|     ■  Avoid using `OpenStruct`; use `Struct`, `Hash`, a class or test doubles instead.
          r = klass.new(res)
          r.save
          r.id
        end)
      end
    end
  end
end
