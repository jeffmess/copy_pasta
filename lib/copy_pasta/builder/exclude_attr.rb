# frozen_string_literal: true

module CopyPasta
  class Builder
    # Takes duplicated attributes and removes data that should not be inserted for the duplications.
    # Primarily primary and foreign keys, but also timestamps.
    #
    # @returns an array of strings. Since we use JSON to do INSERT_ALL
    class ExcludeAttr
      class << self
        # @param options [Hash<String, String>]
        # @param overrides [Hash<String, String>]
        # @return [Array<String>]
        def call(options, overrides)
          case [options, overrides]
          in [nil, nil] then defaults
          in [o, nil]   then flatten_nested_options(o)
          in [nil, l]   then [defaults, l.keys.map(&:to_s)].flatten
          in [o, l]     then [defaults, o.values.map(&:to_s), l.keys.map(&:to_s)].flatten
          end
        end

        private

        def defaults
          %w[id created_at updated_at organisation_id]
        end

        def flatten_nested_options(opt)
          [defaults, opt.flat_map do |_k, v|
            v.is_a?(Symbol) || v.is_a?(Array) ? v : v.values
          end].flatten.map(&:to_s)
        end
      end
    end
  end
end
