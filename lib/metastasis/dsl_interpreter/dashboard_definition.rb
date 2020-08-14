module Metastasis
  class DSLInterpreter
    class DashboardDefinition
      attr_accessor :dashboard, :tag, :dashboard_cards

      def initialize(unique_id)
        @tag = Tag.find_or_initialize_by(target_type: 'Dashboard', name: unique_id)
        @dashboard = if @tag.persisted?
          Dashboard.find_by(id: @tag.target_id)
        else
          Dashboard.new(creator_id: 1, parameters: JSON.dump([]))
        end
        @dashboard_cards = {}
        @parameters = {}
      end

      %i[name creator_id collection_id].each do |n|
        define_method n do |value|
          dashboard.send("#{n}=", value)
        end
      end

      def parameter(name, **args)
        parameter = args.symbolize_keys.slice(:slug, :type)

        parameter[:id] = SecureRandom.alphanumeric(8)
        parameter[:name] = name

        @parameters[name] = parameter
        dashboard.parameters = JSON.dump(@parameters.values)
      end

      def layout(card_unique_id, **options)
        dashboard_card_attributes = { dashboard_id: dashboard.id, parameter_mappings: JSON.dump([]), visualization_settings: {}.to_json }
        card_id = Tag.find_by(target_type: 'Card', name: card_unique_id)&.target_id

        raise "Card `#{card_unique_id}` not found" unless card_id

        dashboard_card_attributes = dashboard_card_attributes.merge(
          DashboardCard.find_or_initialize_by(dashboard_id: dashboard.id, card_id: card_id).attributes.symbolize_keys.slice(:dashboard_id, :card_id, :id)
        )

        if options[:parameter]
          parameter_mappings = options[:parameter].map do |parameter|
            raise "Parameter `#{parameter[:name]}` is not registerd for dashboard" unless @parameters[parameter[:name]]

            { card_id: card_id, parameter_id: @parameters[parameter[:name]][:id], target: ['variable', ['template-tag', parameter[:target]]] }
          end

          parameter_mappings = JSON.dump(parameter_mappings)
          dashboard_card_attributes = dashboard_card_attributes.merge(parameter_mappings: parameter_mappings)
        end

        dashboard_card_attributes = dashboard_card_attributes.merge(options.slice(:sizeX, :sizeY, :row, :col))
        check_area_overlap(card_unique_id, dashboard_card_attributes)

        @dashboard_cards[card_unique_id] = dashboard_card_attributes
      end

      def visualize(card_unique_id, **options)
        raise "Card `#{card_id}` is not laid out on dashboard yet" unless @dashboard_cards[card_unique_id]

        display = options.delete(:display)
        settings = options.map { |type, parameter| parameter.map { |k,v| { "#{type}.#{k}" => v } } }.flatten.inject({}, &:merge)

        card = Card.find(Tag.find_by(target_type: 'Card', name: card_unique_id).target_id)
        card.visualization_settings = settings.merge('graph.show_values' => false).to_json
        card.display = display if display
        card.save!

        @dashboard_cards[card_unique_id][:visualization_settings] = settings.to_json
      end

      private

      def check_area_overlap(card_id, card)
        raise "Card `#{card_id}` is laid out where overlapped with other card" if @dashboard_cards.values.any? { |exists_card| area_overlap?(card, exists_card) }
      end

      def area_overlap?(a, b)
        !(square_range(a)[:x].to_a & square_range(b)[:x].to_a).empty? && !(square_range(a)[:y].to_a & square_range(b)[:y].to_a).empty?
      end

      def square_range(params)
        {
          x: params[:col]...(params[:col] + params[:sizeX]),
          y: params[:row]...(params[:row] + params[:sizeY])
        }
      end
    end
  end
end
