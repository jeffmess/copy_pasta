# frozen_string_literal: true

module CopyPasta
  class Builder
    # Use this class when you need to update a foreign key for a self joined table.
    class UpdateSelfAssoc
      # rubocop:disable Metrics/AbcSize
      # @param zipped Array<Hash<Int, Int>> (The zipped tree for this specific table)
      # @param klass Class (Class name for the active record model)
      # @param options Hash (contains the foreign keys to update)
      # @param table_name
      def call(zipped:, klass:, options:, table_name:, collection:)
        # TODO: document return vals
        return unless options[table_name].is_a? Symbol

        items = collection.select { |item| item.send(options[table_name]).present? }
        to_update = items.map do |item|
          { id: zipped[table_name][item.id],
            options[table_name] => zipped[table_name][item.send(options[table_name])] }
        end

        klass_values = convert(to_update)
        klass.update(klass_values.keys, klass_values.values)
      end
      # rubocop:enable Metrics/AbcSize

      private

      def convert(array)
        array.each_with_object({}) do |item, hsh|
          hsh[item[:id]] = item.except(:id)
        end
      end
    end
  end
end
