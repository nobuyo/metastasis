module Metastasis
  class MetabaseField < ActiveRecord::Base
    self.table_name = 'metabase_field'

    belongs_to :metabase_table
  end
end
