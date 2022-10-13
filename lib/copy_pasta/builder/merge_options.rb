# frozen_string_literal: true

module CopyPasta
  class Builder
    # This class is responsible for calculating foreign key relationships
    #
    # @inst represents an instance of an ActiveRecord::Model
    # @tree is a hash of data used to determine the relationship
    # @options is a hash of foreign_keys with the following supported types
    #  - Value for belongs_to
    #  - Array for belongs_to, class_name: "X"
    #  - Hash for polymorphic associations
    # @to is an instance of an Organisation
    #
    # @example
    #   comment = Comment.first # Assume we have a comment where the commentable rel is a Member
    #   options = { :comments => :parent_id,
    #               :commentables=>{ :class_name=>:commentable_type, :class_id=>:commentable_id},
    #               :users=>:user_id,
    #               :members=>:member_id }
    #   tree    = {:members=>{ 1 => 2 }, :users=>{ 1 => 1}}
    #
    #   MergeOptions.new(options, tree, comment, Organisation.first)
    #   => {
    #       :created_at=>...,
    #       :updated_at=>...,
    #       :parent_id=>nil,
    #       :commentable_type=>"Member",
    #       :commentable_id=>2,
    #       :user_id=>2,
    #       :member_id=>2
    #     }
    #
    # @return Hash
    class MergeOptions
      # rubocop:disable Metrics/ParameterLists
      def initialize(options:, tree:, inst:, to:, timestamps: true, copy_timestamps: false)
        @options = options
        @tree    = tree
        @inst    = inst
        @to      = to
        @hash    = timestamps ? { created_at: Time.now, updated_at: Time.now } : {}
        @hash    = copy_timestamps ? { created_at: inst.created_at, updated_at: inst.updated_at } : @hash
      end
      # rubocop:enable Metrics/ParameterLists

      def call
        return @hash if @options.blank?

        @options.map do |k, v|
          case v
          in Hash  then process_hash(k, v)
          in Array then process_array(k, v)
          in _     then process_item(k, v)
          end
        end

        @hash
      end

      def process_hash(key, hash)
        assoc = @inst.send(key.to_s.singularize)
        return if assoc.nil?

        table_name = assoc.class.table_name.to_sym
        @hash[hash[:class_name]] = @inst.send(hash[:class_name])
        if table_name == :organisations
          @hash[hash[:class_id]] = @to.id
        else
          process_item(table_name, hash[:class_id])
        end
      end

      def process_array(key, array)
        array.each do |elem|
          process_item(key, elem)
        end
      end

      def process_item(key, value)
        @hash[value] = nil
        return if @tree[key].nil?
        return if @tree[key].is_a? Array # self ref relationship. escape early.

        @hash[value] = @tree[key][@inst.send(value)] unless @inst.send(value).nil?
      end
    end
  end
end
