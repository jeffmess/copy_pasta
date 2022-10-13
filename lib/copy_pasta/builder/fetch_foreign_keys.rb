# frozen_string_literal: true

module CopyPasta
  module Builder
    # Builds a Hash based off a ActiveRecord::Reflection::BelongsToReflection array
    # This hash is used to pass into the Builder to map relations across
    class FetchForeignKeys
      class << self
        # @example
        #   rels = SomeModel.reflect_on_all_associations(:belongs_to)
        #   FetchForeignKeys.call(rels)
        #   => { :users=>:user_id }
        #
        # @param relations [ActiveRecord::Reflection::BelongsToReflection]
        # @return [Hash] # belongs_to => { :users=>:user_id }
        # @return [Hash] # belongs_to with custom class_name => {:members=>[:checked_by_id, :member_id] }
        # @return [Hash] # polymorphic belongs_to :commentables=>{:class_name=>:commentable_type,
        #                                                         :class_id=>:commentable_id},
        # @api public
        def call(relations)
          relations
            # .reject { |r| r.name == multi_tenancy_id } # TODO
            .inject({}) do |hash, v|
              build_hash(v, hash)
            end
        end

        private

        # rubocop:disable Metrics/AbcSize
        def build_hash(relation, hash)
          case [relation, relation.options]
          in [r, o] if o.key?(:class_name)
            upsert_hash(hash, r.options[:class_name].constantize.table_name.to_sym, r.join_keys.foreign_key.to_sym)
          in [r, { polymorphic: true }]
            upsert_polymorphic_hash(hash, r.name.to_s.pluralize.to_sym, r.foreign_type.to_sym, r.foreign_key.to_sym)
          in [r, _]
            upsert_hash(hash, r.name.to_s.pluralize.to_sym, r.join_keys.foreign_key.to_sym)
          end
          hash
        end
        # rubocop:enable Metrics/AbcSize

        def upsert_hash(hash, key, value)
          if hash.key? key
            hash[key] = [hash[key]] unless hash[key].is_a? Array
            hash[key] << value
          else
            hash[key] = value
          end
          hash
        end

        def upsert_polymorphic_hash(hash, key, class_name, class_id)
          hash[key] = { class_name: class_name, class_id: class_id }
          hash
        end
      end
    end
  end
end
