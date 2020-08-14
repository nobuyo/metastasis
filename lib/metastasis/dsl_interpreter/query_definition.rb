module Metastasis
  class DSLInterpreter
    class QueryDefinition
      attr_accessor :card, :tag

      def initialize(unique_id, **options)
        @tag = Tag.find_or_initialize_by(target_type: 'Card', name: unique_id)
        @card = if @tag.persisted?
          Card.find_by(id: @tag.target_id)
        else
          Card.new(creator_id: 1, display: :table, visualization_settings: {})
        end
        @template_tags = {}
        @dataset_query = {}

        options[:query_config].each do |k, v|
          self.send(k, v)
        end
      end

      %i[name visualization_settings display creator_id collection_id].each do |n|
        define_method n do |value|
          card.send("#{n}=", value)
        end
      end

      def database_id(value)
        card.database_id = value
        @dataset_query = @dataset_query.merge(database: value)
        card.dataset_query = @dataset_query.to_json
      end

      def query_type(value)
        card.query_type = value
        @dataset_query = @dataset_query.merge(type: value)
        card.dataset_query = @dataset_query.to_json
      end

      def query(value)
        key = @dataset_query[:query_type] || :native
        @dataset_query[key] = (@dataset_query[key] || {}).merge({ query: value })
        card.dataset_query = @dataset_query.to_json
      end

      def parameter(name, **args)
        args = args.symbolize_keys

        args[:name] = name
        args[:'display-name'] = args.delete(:display_name)

        if args[:type] == 'dimension'
          table_name, column_name = args.delete(:target).split('.')
          table = Metastasis::MetabaseTable.find_by(name: table_name)
          column = Metastasis::MetabaseField.find_by(table_id: table.id, name: column_name)

          args[:dimention] = ['field-id', column.id]
          args[:'widget-type'] = args.delete(:widget_type)
        end

        args[:id] = SecureRandom.uuid

        @template_tags[name] = args
        key = @dataset_query[:query_type] || :native
        @dataset_query[key] = (@dataset_query[key] || {}).merge('template-tags' => @template_tags)

        card.dataset_query = @dataset_query.to_json
      end
    end
  end
end
