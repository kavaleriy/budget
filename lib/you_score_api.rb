class YouScoreApi
  def self.set_financial_scoring
    enterprises = Municipal::Enterprise.all
    enterprises.each do |enterprise|
      scoring_years = ExternalApi.financial_scoring(enterprise.edrpou)

      scoring_years.each do |scoring_year|
        binding.pry
        edrpou_hash = { edrpou: enterprise.edrpou, year: scoring_year[:year]}
        scoring_year.merge(edrpou_hash)
        json = File.read('public/group.json')

        File.open('public/group.json', 'w') do |f|
          f.puts JSON.pretty_generate(JSON.parse(json) << scoring_year)
        end

        scoring_data = ExternalApi.financial_scoring_per_year(enterprise.edrpou, scoring_year[:year])
        financial_scores = YouScore::FinancialScore.find_or_initialize_by(enterprise: enterprise.id)

        scoring_data.merge(edrpou_hash)
        json = File.read('public/group.json')

        File.open('public/group_scores.json', 'w') do |f|
          f.puts JSON.pretty_generate(JSON.parse(json) << edrpou_hash)
        end

        financial_scores.enterprise = enterprise.id
        financial_scores.year = scoring_year[:year]
        financial_scores.score_mark = scoring_data[:score][:mark]
        financial_scores.score_value = scoring_data[:score][:value]
        financial_scores.current_ratio = scoring_data[:currentRatio]
        financial_scores.cash_ratio = scoring_data[:cashRatio]
        financial_scores.equity_to_assets = scoring_data[:equityToAssets]
        financial_scores.roa = scoring_data[:roa]
        financial_scores.rca = scoring_data[:rca]
        financial_scores.npm = scoring_data[:npm]
        financial_scores.total_assets_turnover = scoring_data[:totalAssetsTurnover]
        financial_scores.working_capital_turnover = scoring_data[:workingCapitalTurnover]
        financial_scores.receivables_turnover = scoring_data[:receivablesTurnover]
        binding.pry
        financial_scores.save
      end

    end
  end

  def self.set_tax_debt
    enterprises = Municipal::Enterprise.all
    enterprises.each do |enterprise|
      tax_debt = ExternalApi.tax_debt(enterprise.edrpou)

      edrpou_hash = { edrpou: enterprise.edrpou }
      tax_debt.merge(edrpou_hash)
      json = File.read('public/group_debt.json')

      File.open('public/group_debt.json', 'w') do |f|
        f.puts JSON.pretty_generate(JSON.parse(json) << tax_debt)
      end

      enterprise.debt = tax_debt[:debt]
      enterprise.actual_date = tax_debt[:actualDate]
      enterprise.save
    end
  end

end