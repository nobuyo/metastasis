module Metastasis
  class Dashboard < ActiveRecord::Base
    self.table_name = 'report_dashboard'

    has_many :dashboard_cards
    accepts_nested_attributes_for :dashboard_cards
  end
end