class TaxonomyRot < Taxonomy
  COLUMNS = {
      '_box' =>{:title=>'Кошик'},
      'fond'=>{:title=>'Фонд'},
      'kkd_a'=>{:title=>'Розряд 1'},
      'kkd_bb'=>{:title=>'Розряд 1-3'},
      'kkd_cc'=>{:title=>'Розряд 1-5'},
      'kkd_ddd'=>{:title=>'Розряд 1-8'}
  }

  def self.get_taxonomy(name)
    TaxonomyRot.create!(
        :name => name,
        :columns => COLUMNS
    )
  end

  # dbf.reject { |rec| rec.summ.nil? || rec.summ == 0 }.each do |rec|
  #   key = rec.kkd.to_s
  #   amount = rec.summ / 100
  #
  #   row = { :amount => amount }
  #   [{t: 'kkd_a', key: key.slice(0, 1)}, {t: 'kkd_bb', key: key.slice(0, 3)}, {t: 'kkd_cc', key: key.slice(0, 5)}, {t: 'kkd_ddd', key: key.slice(0, 8)}].each do |v|
  #     row[v[:t]] = v[:key]
  #   end
  #   self.rows << row
  # end

end
