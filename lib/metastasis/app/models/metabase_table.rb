module Metastasis
  class MetabaseTable < ActiveRecord::Base
    self.table_name = 'metabase_table'

    belongs_to :metabase_table
  end
end
