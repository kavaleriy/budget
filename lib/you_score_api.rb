class YouScoreApi
  def self.set_tax_debt
    enterprises = Municipal::Enterprise.all

    data = []
    enterprises.each_with_index do |enterprise, i|
      tax_debt = ExternalApi.tax_debt(enterprise.edrpou)
      # @edr_data_bot = ExternalApi.data_bot_edr(enterprise.edrpou).first
      # tax_debt = @edr_data_bot && @edr_data_bot.try(:key?, 'full_name') ? @edr_data_bot : { message: 'no data'}

      edrpou_hash = { edrpou: enterprise.edrpou, enterprise_id: enterprise.id.to_s}
      data << tax_debt.merge(edrpou_hash)

      enterprise.debt = tax_debt['debt']
      enterprise.actual_date = tax_debt['actualDate']
      enterprise.save
    end

    file_path = Rails.root.join('public', 'group_debt.json')
    File.open(file_path, 'w') do |f|
      f.puts JSON.pretty_generate(data)
    end
  end

  def self.financial_scoring
    @enterprises = Municipal::Enterprise.all
    @enterprises.each do |enterprise|
      set_financial_scoring(enterprise.id, enterprise.edrpou)
    end
  end

  def self.set_financial_scoring(id, edrpou)
    scoring_years = ExternalApi.financial_scoring(edrpou)

    # company_data = ExternalApi.data_bot_decisions(edrpou)
    # scoring_years = company_data['items'].present? ? company_data['items'] : { 'message' => 'no data'}

    ent_data = { edrpou: edrpou, enterprise_id: id.to_s, scores: [] }
    # scoring_years[0..2].each do |scoring_year|
    scoring_years.each do |scoring_year|
      scoring_data = ExternalApi.financial_scoring_per_year(edrpou, scoring_year['year'])
      data = scoring_data.merge({ year: scoring_year['year'] })
      ent_data[:scores] << data

      financial_scores = YouScore::FinancialScore.find_or_initialize_by(enterprise: id, year: scoring_year['year'])
      financial_scores.enterprise = id
      financial_scores.year = scoring_year['year']
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
      binding.pry
      financial_scores.save
    end

    group_file_path = Rails.root.join('public', 'group.json')
    json = File.read(group_file_path)
    File.open(group_file_path, 'w') do |f|
      f.puts JSON.pretty_generate(JSON.parse(json) << ent_data)
    end

  end

end