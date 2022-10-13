# frozen_string_literal: true

module CopyPasta
  class Builder
    # This class is responsible for performing an insert_all
    class Insert
      # @param klass [ActiveRecord::Model] # Class name for model
      # @param items [Array<JSON>] # Array of json objects to insert
      # @return [Array<Integer>] # Array of ids inserted
      def call(klass, items)
        # TODO: pass in primary key if `id` is not the primary key
        klass.insert_all!(items, returning: :id)
      end
    end
  end
end
