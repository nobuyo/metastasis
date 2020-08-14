module Metastasis
  class DashboardCard < ActiveRecord::Base
    self.table_name = 'report_dashboardcard'

    belongs_to :card
    belongs_to :dashboard

    validates :sizeX, presence: true
    validates :sizeX, presence: true
    validates :row,   presence: true
    validates :col,   presence: true
  end
end