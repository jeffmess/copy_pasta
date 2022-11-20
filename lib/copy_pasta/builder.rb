# frozen_string_literal: true

module CopyPasta
  # Private class called by DSL#build
  class Builder
    attr_accessor :from, :to, :model, :tree, :options, :parent, :overrides, :keep_timestamps

    attr_reader :tables

    def invoke!
      items = map_data
      return @tree if items.blank?

      response_data = insert(items)
      zipped = zip_tree(response_data)
      post_update(zipped)

      Success(zipped)
    end

    def validate
      return unless @from_collection.nil?

      raise CollectionError.new(message: 'No data supplied to copy. Data is nil and should be an array')
    end

    # @param value: Organisation
    # def from_org(org)
    #   @from = org
    # end
    def source(src)
      @from = src
    end

    def with_tables(tables)
      @tables = tables
    end

    # @param value: Organisation
    def destination(dest)
      @to = dest
    end

    # @param value: String
    # @todo - might be worth passing in the Model type itself
    def from_model(model)
      @model = model
    end

    # @param value: Bool
    def with_timestamps(bool = false)
      @keep_timestamps = bool
    end

    # Must be of a type Tree. Initial value must be empty array which
    # will be amended to a hash map linking to the original record.
    #
    # @example { table_name: [ids] }
    def with_tree(tree)
      @tree = tree
    end

    # Maps tree key to value on table
    #
    # @example { qualifications: :qualification_id}
    def with_foreign_keys(options)
      @options = options
    end

    # Array of data to be copied
    def using_data(data)
      @from_collection = data
    end

    # The parent is the organisation. Setting this to true
    # will inject organisation_id: @to.id into the insert
    # params.
    def with_parent(boolean)
      @parent = boolean
    end

    # Some cases we have unique constraints in the database which
    # will prevent insertion. Custom overrides allows us to pass
    # around a lambda which will inject itself into the insertion
    # method. See Users::CopyMembers for usage.
    # @example
    #   api_key = lambda {
    #     random_token = Digest::SHA1.hexdigest([Time.now, rand(111..999)].join)
    #     loop do
    #       break unless Member.exists?(api_key: random_token)
    #       random_token = random_string
    #     end
    #     { api_key: random_token }
    #   }
    #   builder = Builder.new.with_custom_overrides(api_key)
    #
    # Must return a Hash since we inject this value into the merge_options.
    def with_custom_overrides(a_lambda)
      @overrides = a_lambda
    end

    private

    # @private
    # zips the new data and the old data together to use for referencing
    def zip_tree(response)
      @tree[table_name] = @tree[table_name].zip(response.rows.flatten).to_h if primary_key?
      @tree
    end

    # @private
    # Maps over the data, duplicates and amends the data based on constraints
    # passed in by the caller.
    # Relies on `Model.to_json` to fetch models attributes.
    # @returns Success(Array[entries])
    def map_data
      @from_collection.map do |i|
        @tree[table_name] << i.id if primary_key? # assumes pk is :id
        JSON
          .parse(i.dup.to_json)
          .except!(*exclude)
          .merge(merge_options(i))
      end
    end

    def primary_key?
      # used to determine whether a table
      @primary_key ||= klass.primary_key.present?
    end

    def klass
      @klass ||= @model.constantize
    end

    def table_name
      @table_name ||= klass.table_name.to_sym
    end

    def sti?
      # sti_name might be deprecated...
      klass.column_names.include?('type')
    end

    def self_key_refs?
      # check if there are any keys that reference itself. Self Joined Table.
      !!options&.key?(table_name)
    end

    def uploader?
      klass.uploaders&.dig(:attachment).present? || klass.uploaders&.dig(:file).present?
    end

    # Inserts all the records into the specified table.
    # Utilises `insert_all` which skips all ActiveRecord validations
    # and callbacks.
    #
    # This Method will only catch RecordNotUnique errors. All other
    # errors will raise and bubble up.
    #
    # @param Array[entries]
    # @returns Failure(RecordNotUnique)
    # @returns Success(Obj<rows: [Int]>)
    def insert(items)
      case [primary_key?, uploader?]
      in [true, false]  then Insert.new.call(klass, items)
      in [false, false] then InsertJoinTable.new.call(klass, items)
      in [true, true]   then InsertEach.new.call(klass, items, @from_collection)
      in _              then [] # should not get here. means it has an upload and no pk.
      end
    end

    def post_update(zipped)
      return if self_key_refs?

      UpdateSelfAssoc.new.call(zipped: zipped, klass: klass, options: options, table_name: table_name,
                               collection: @from_collection)
    end

    # Calls the lambda if one exists otherwise returns nil.
    # Might need to add a feature here where we acn pass options into the lambda.
    # Not to be used by `merge_options` since we want to invoke that for every
    # item in the collection we are duplicating.
    def override_options
      @overrides&.lambda? ? @overrides.call(nil) : nil
    end

    # Default attributes to be excluded from insertion
    def exclude
      ExcludeAttr.call(options, override_options)
    end

    def merge_options(inst)
      hash = MergeOptions.new(options, tree, inst, to, primary_key?, keep_timestamps).call
      hash[:type] = inst.type if sti?
      hash[:organisation_id] = @to.id if @parent
      hash.merge!(@overrides.call(inst)) if @overrides&.lambda?
      hash
    end
  end
end

