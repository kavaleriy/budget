class BudgetFileRovVd < BudgetFile

  protected

  def readline row
    ktfk = row['KTFK'].to_i.to_s.gsub(/^0*/, "")
    kpk = row['KPK'].to_s

    fond = row['KF'].to_s.split('.')[0]

    kekv = row['KEKV'].to_s.split('.')[0]

    return if (ktfk =~ /000$/) != nil
    return if (ktfk =~ /^900$/) != nil
    return unless kekv.length == 4
    return if is_grouped_kekv kekv

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'

    kvk = row['KVK'].to_s.split('.')[0]
    krk = row['KRK'].to_s.split('.')[0]

    [
        { :amount => row['KVNP'].to_f / 100 },
    ].map do |line|
      next if line[:amount] == 0
      item = rov_get_item_by_code(ktfk, kpk)

      dt = row['DT'].to_date

      item.merge({
          'amount' => line[:amount],
          'fond' => fond,
          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,
          'kekv' => kekv,
          'kvk' => kvk,
          'krk' => krk,
          '_year' => dt.year.to_s,
          '_month' => dt.month.to_s,
      })
    end.reject {|c| c.nil?}
    # end.reject {|c| c.nil? || (c['ktfk'] =~ /000$/) != nil}
  end

end
