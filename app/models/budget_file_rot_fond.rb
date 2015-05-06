class BudgetFileRotFond < BudgetFileRot

  protected

  def get_taxonomy owner, columns
    TaxonomyRot.get_taxonomy(owner)
  end

  def readline row
    kkd = row['kkd'].to_s.split('.')[0]
    return if kkd == ''

    amount1 = row[I18n.t('mongoid.taxonomy_rot_fond.gen_fund')].to_i
    amount2 = row[I18n.t('mongoid.taxonomy_rot_fond.spec_fund')].to_i

    [
        { :amount => amount1, :fond => '1' },
        { :amount => amount2, :fond => '7' },
    ].map { |line|

      fond = line[:fond]
      amount = line[:amount] / 100

      item = {
          'amount' => amount,
          'fond' => fond,
      }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }


      [{t: 'kkd_a', key: kkd.slice(0, 1)}, {t: 'kkd_bb', key: kkd.slice(0, 3)}, {t: 'kkd_cc', key: kkd.slice(0, 5)}, {t: 'kkd', key: kkd.slice(0, 8)}].map { |v|
        item[v[:t]] = v[:key]
      }
      item
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

  def set_data_type
    self.data_type = :plan if self.data_type.nil?
  end

end
