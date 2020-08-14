module Metastasis
  class Tag < ActiveRecord::Base
    self.table_name = 'metastasis_tags'

    validates :name, presence: true
    validates :name, uniqueness: true
  end
end
