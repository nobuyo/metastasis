module Metastasis
  class DSLInterpreter
    class Context
      attr_reader :options

      def initialize(options)
        @__working_dir = File.expand_path(File.dirname(options[:definition_file]))
        @options = options
      end

      def self.eval(dsl, **options)
        context = new(options)
        context.instance_eval(dsl)
      end

      def register_card(unique_id)
        unique_id = unique_id.to_s
        query_definition = QueryDefinition.new(unique_id, options)

        yield(query_definition)

        query_definition.card.save!
        query_definition.tag.target_id = query_definition.card.id
        query_definition.tag.save!
      end

      def register_dashboard(unique_id)
        unique_id = unique_id.to_s
        dashboard_definition = DashboardDefinition.new(unique_id)

        yield(dashboard_definition)

        dashboard_definition.dashboard.dashboard_cards_attributes = dashboard_definition.dashboard_cards
        dashboard_definition.dashboard.save!
        dashboard_definition.tag.target_id = dashboard_definition.dashboard.id
        dashboard_definition.tag.save!
      end

      def require(file)
        definition_file = %r{\A/}.match?(file) ? file : File.join(@__working_dir, file)

        if File.exist?(definition_file)
          instance_eval(File.read(definition_file), definition_file)
        else
          Kernel.require(file)
        end
      end
    end
  end
end
