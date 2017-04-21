class BudgetFileRov < BudgetFile

  protected

  def readline row
    ktfk = row['KTFK'].to_i.to_s.gsub(/^0*/, "")
    kpk = row['KPK'].to_s

    amount = row['SUMM'].to_i
    return if amount.nil? || amount == 0

    fond = row['KKFN'].to_s.split('.')[0]
    # return unless is_allowed_fond(fond)

    kekv = row['KEKV'].to_s.split('.')[0]
    return if is_grouped_kekv kekv

    kod =  row['KOD'].to_s.split('.')[0]
    return if fond != '1' and kod == '1'

    # calc special fond annual amount
    month = row['MONTH'].to_s.split('.')[0]
    return if fond == '7' and month == '0' and ktfk.blank? # since 2017 this patch is outdated
    months = [ month ]
    months << '0' if fond == '7' # add annual amount manually

    year = row['_year'] || row['DATA'].to_date.year.to_s.split('.')[0]

    months.map do |mon|
      item = parse_rov_code(year, ktfk, kpk)

      item.merge!({
        '_year' => year,
        '_month' => mon,

        'fond' => fond,

        'amount' => amount / 100,
        'kvk' => row['KVK'].to_s.split('.')[0],
        'kekv' => kekv,
        'krk' => row['KRK'].to_s.split('.')[0],
      })
    end
  end

end
