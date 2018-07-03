# frozen_string_literal: true
module Municipal
  # financial score for enterprise
  class FinancialScore
    include Mongoid::Document
    include Mongoid::Timestamps

    field :year, type: Integer
    field :score_mark, type: Float
    field :score_value, type: Float
    field :current_ratio, type: Float
    field :cash_ratio, type: Float
    field :equity_to_assets, type: Float
    field :roa, type: Float
    field :rca, type: Float
    field :npm, type: Float
    field :total_assets_turnover, type: Float
    field :working_capital_turnover, type: Float
    field :receivables_turnover, type: Float

    belongs_to :enterprise, class_name: 'Municipal::Enterprise'
  end

end