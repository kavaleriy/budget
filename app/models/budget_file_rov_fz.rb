class BudgetFileRovFz < BudgetFile

  protected

  def readline row
    return unless row['type_rozd'].to_s == '1'

    return if row['tf'].to_s == '3'

    return unless row['kmb'].to_s == self.taxonomy.kmb

    kpk = row['fcode'].to_s.ljust(7, '0')
    # return if (ktfk =~ /000$/) != nil
    # return if (ktfk =~ /^900/) != nil

    kekv = row['ecode'].to_s
    return unless kekv.length == 4
    return if is_grouped_kekv kekv

    fond = row['cf'].to_s
    # return unless is_allowed_fond(fond)

    kod =  row['KOD'].to_s.split('.')[0]
    # return if fond != '1' and kod == '1'

    kvk = row['kvk'].to_s


    # ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    # ktfk_aaa = '80' if ktfk_aaa == '81'
    # ktfk_aaa = '90' if ktfk_aaa == '91'

    year = row['_year']

    generate_item = ->(amount, month) do
      item = rov_get_item_by_code(nil, kpk)      
      
      item.merge({
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

    items = (0..12).map do |i|
      amount = row["m#{i}"].to_f

      next if amount == 0

      generate_item.call(amount, i)
    end.reject {|c| c.nil?}
    # end.reject {|c| c.nil? || (c['ktfk'] =~ /000$/) != nil}


    items
  end

end
