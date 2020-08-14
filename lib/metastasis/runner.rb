module Metastasis
  class Runner
    attr_reader :config, :options

    def initialize(options)
      @options = options
      @config = load_config_file[options[:environment]]
      @options = @options.merge(query_config: @config.delete('query_config')&.symbolize_keys || {})

      Time.zone = options[:timezone]
      ActiveRecord::Base.time_zone_aware_attributes = true

      ActiveRecord::Base.establish_connection(@config)
    end

    def apply
      add_migration_ledger
      dsl = load_dsl
      Metastasis::DSLInterpreter.new(options).execute(dsl)
    end

    private

    def load_config_file
      YAML.safe_load(
        ERB.new(
          File.read(options[:config_file])
        ).result,
        [], [], true
      )
    end

    def load_dsl
      raise "No definition file found (looking for: #{options[:definition_file]})" unless File.exist?(options[:definition_file])

      raw_dsl = File.read(options[:definition_file])
    end

    def add_migration_ledger
      return if ActiveRecord::Base.connection.table_exists?(:metastasis_tags)

      ActiveRecord::Base.connection.create_table :metastasis_tags do |t|
        t.string :target_type, null: false
        t.bigint :target_id,   null: false
        t.string :name,        null: false

        t.index :name, unique: true
      end
    end
  end
end
