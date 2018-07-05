class YouScoreApi
  # set tax_debts for all enterprises
  def self.tax_debts
    enterprises = Municipal::Enterprise.all

    enterprises.each do |enterprise|
      set_tax_debt(enterprise)
    end
    p 'finish'
  end

  # set tax_debt for enterprise
  def self.set_tax_debt(enterprise)
    tax_debt = ExternalApi.tax_debt(enterprise.edrpou)

    enterprise.debt = tax_debt['debt']
    enterprise.actual_date = tax_debt['actualDate']
    enterprise.debt_checked = Time.now
    enterprise.save
  end

  # set scores for all enterprises
  def self.financial_scoring
    @enterprises = Municipal::Enterprise.all
    @enterprises.each do |enterprise|
      set_financial_scoring(enterprise)
    end
  end

  # set financial_scoring for enterprise
  def self.set_financial_scoring(enterprise)
    # get years with scores
    scoring_years = ExternalApi.financial_scoring(enterprise.edrpou)

    if scoring_years.kind_of?(Array)
      scoring_years.each do |scoring_year|
        # next if financial_scores exists
        financial_scores = Municipal::FinancialScore.find_or_initialize_by(enterprise: enterprise.id, year: scoring_year['year'])
        next if financial_scores.score_mark.present?

        # get scores for year and set values to financial_scores
        scoring_data = ExternalApi.financial_scoring_per_year(enterprise.edrpou, scoring_year['year'])
        financial_scores.score_mark = scoring_data['score']['mark']
        financial_scores.score_value = scoring_data['score']['value']
        financial_scores.current_ratio = scoring_data['currentRatio']
        financial_scores.cash_ratio = scoring_data['cashRatio']
        financial_scores.equity_to_assets = scoring_data['equityToAssets']
        financial_scores.roa = scoring_data['roa']
        financial_scores.rca = scoring_data['rca']
        financial_scores.npm = scoring_data['npm']
        financial_scores.total_assets_turnover = scoring_data['totalAssetsTurnover']
        financial_scores.working_capital_turnover = scoring_data['workingCapitalTurnover']
        financial_scores.receivables_turnover = scoring_data['receivablesTurnover']

        financial_scores.save
      end
    end

    enterprise.scores_checked = Time.now
    enterprise.save
  end

end