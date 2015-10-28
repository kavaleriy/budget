class BudgetFileRovVd < BudgetFile

  protected

  def readline row
    ktfk = row['KTFK'].to_s.split('.')[0].gsub(/^0*/, "")
    kekv = row['KEKV'].to_s.split('.')[0]

    return if (ktfk =~ /000$/) != nil
    return if (ktfk =~ /^900$/) != nil
    return unless kekv.length == 4

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'

    fond = row['KF'].to_s.split('.')[0]

    [
        { :amount => row['VKNP'].to_i, :amount_type => :plan },
        { :amount => row['KVNP'].to_i, :amount_type => :fact },
    ].map do |line|
      next if line[:amount].to_i == 0

      item = {
          'amount' => line[:amount],
          'fond' => fond,
          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,
          'kekv' => kekv,
          '_amount_type' => line[:amount_type],
      }

      dt = row['DT'].to_date
      item['_year'] = dt.year.to_s

      item
    end.reject {|c| c.nil? || (c['ktfk'] =~ /000$/) != nil}
  end

end
