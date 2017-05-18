class BudgetFileRovFz < BudgetFile

  protected

  def readline row
    return unless row['TYPE_ROZD'].to_s == '1'

    return if row['TF'].to_s == '3'

    return unless self.taxonomy.kmb.blank? || row['KMB'].to_s == self.taxonomy.kmb

    year = row['_year'] || row['D_UTV'].to_date.year.to_s

    kvk = row['KVK'].to_s

    ktfk = row['FCODE'].to_s

    kpk = row['FCODE'].to_s
    return if kpk.length == 6 && year.to_i > 2016
    kpk = kvk + kpk.rjust(7 - kvk.length, '0') if kpk.length < 6

    kekv = row['ECODE'].to_s
    return unless kekv.length == 4
    return if is_grouped_kekv kekv

    fond = row['CF'].to_s
    # return unless is_allowed_fond(fond)

    kod =  row['KOD'].to_s.split('.')[0]
    # return if fond != '1' and kod == '1'


    generate_item = ->(amount, month) do
      item = parse_rov_code(year, ktfk, kpk)

      item.merge!({
          'amount' => amount,
          'fond' => fond,
          'kvk' => kvk,
          'kekv' => kekv,
          'krk' => row['KRK'].to_s.split('.')[0],
          '_year' => year,
          '_month' => month.to_s
      })
      return item
    end

    items = (1..12).map do |i|
      amount = row["M#{i}"].to_f

      next if amount == 0

      generate_item.call(amount, i)
    end.reject {|c| c.nil?}
    # end.reject {|c| c.nil? || (c['ktfk'] =~ /000$/) != nil}

    annual_amount = items.map {|s| s['amount']}.sum
    items << generate_item.call(annual_amount, 0)

    items
  end

end
