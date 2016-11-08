class BudgetFileRovVz < BudgetFile

  protected

  def readline row
    ktfk = row['KFK'].to_s

    kekv = row['KOD'].to_s

    return unless kekv.length == 4

    return if is_grouped_kekv kekv

    return if (ktfk =~ /000$/) != nil
    return if (ktfk =~ /^900/) != nil

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa == '81'
    ktfk_aaa = '90' if ktfk_aaa == '91'

    kvk = row['KVK'].to_s

    [
        { :amount => row['N1'].to_i, :fond => 1, :amount_type => :plan },
        { :amount => row['N4'].to_i, :fond => 7, :amount_type => :plan },
        { :amount => row['N3'].to_i, :fond => 1, :amount_type => :fact },
        { :amount => row['N6'].to_i, :fond => 7, :amount_type => :fact },
    ].map do |line|
      next if line[:amount].to_i == 0

      item = {
          '_amount_type' => line[:amount_type],
          'amount' => line[:amount],
          'fond' => line[:fond],
          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,
          'kvk' => kvk,
          'kekv' => kekv,
      }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      item
    end.reject {|c| c.nil? || (c['ktfk'] =~ /000$/) != nil}
  end

end
