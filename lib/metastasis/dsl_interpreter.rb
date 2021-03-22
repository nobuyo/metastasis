module Metastasis
  class DSLInterpreter
    attr_reader :options
    def initialize(**options)
      @options = options
    end

    def execute(dsl)
      ActiveRecord::Base.transaction do
        Context.eval(dsl, **options)
      end
    rescue ActiveRecord::RecordNotUnique
      raise 'Something is defined more than once'
    # rescue ActiveRecord::RecordInvalid
    #   raise 'Some required options are missing'
    end
  end
end
