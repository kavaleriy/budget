class BudgetFileRotFz < BudgetFile

  protected

  def readline row
    return unless row['type_rozd'].to_s == '2'
    return if row['tf'].to_s == '3'
    return unless row['kmb'].to_s == self.taxonomy.kmb

    kkd = row['fcode'].to_s

    fond = row['cf'].to_s
    return unless is_allowed_fond(fond)

    return if %w(90010100 90010200 90010300).include?(kkd)

    kkd_a = kkd.slice(0, 1)
    kkd_b = kkd.slice(0, 2)
    kkd_cc = kkd.slice(0, 4)
    kkd_dd = kkd.slice(0, 6)

    generate_item = ->(amount, month) do
      item = {
          'amount' => amount,
          'fond' => fond,
          '_month' => month.to_s
      }

      # %w(_year _month).each{ |key|
      #   item[key] = row[key].to_i unless row[key].nil?
      # }

      [{t: 'kkd_a', key: kkd_a}, {t: 'kkd_b', key: kkd_b}, {t: 'kkd_cc', key: kkd_cc}, {t: 'kkd_dd', key: kkd_dd}, {t: 'kkd', key: kkd}].map { |v|
        item[v[:t]] = v[:key]
      }
      return item
    end

    items = (1..12).map do |i|
      amount = row["m#{i}"].to_f

      next if amount == 0

      generate_item.call(amount, i)
    end.reject {|c| c.nil? || (c['kkd_dd'] =~ /00$/) != nil}

    annual_amount = items.map {|s| s['amount']}.sum
    items << generate_item.call(annual_amount, 0)

    items
  end

end
