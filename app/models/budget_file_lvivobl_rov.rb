class BudgetFileLvivoblRov < BudgetFile

  protected

  def readline row

    ktfk = row['Код'].to_s.gsub(/\s+/, "").split('.')[0]
    return if ktfk.to_i == 0
    return if ktfk.match Regexp.new(".*000$")
    return if ktfk.length < 5

    ktfk.gsub!(/^800/, "80")
    ktfk.gsub!(/^900/, "90")

    ktfk_aaa = ktfk.slice(0, ktfk.length - 3) #.ljust(3, '0')
    ktfk_aaa = '80' if ktfk_aaa.in?(['800', '81'])
    ktfk_aaa = '90' if ktfk_aaa.in?(['900', '91'])

    kekv = row['Економічна класифікація'].to_s.split('.')[0].gsub(/^0*/, "")
    kekv = '-' if kekv.blank?

    [
        { :amount => row['Загальний фонд - план'].to_i, :amount_type => :plan, :fond => 1 },
        { :amount => row['Загальний фонд - факт'].to_i, :amount_type => :fact, :fond => 1 },
        { :amount => row['Спеціальний фонд - план'].to_i, :amount_type => :plan, :fond => 7 },
        { :amount => row['Спеціальний фонд - факт'].to_i, :amount_type => :fact, :fond => 7 },
    ].map { |line|
      next if line[:amount] == 0

      item = {
          'amount' => line[:amount],

          'fond' => line[:fond],

          'ktfk' => ktfk,
          'ktfk_aaa' => ktfk_aaa,

          # 'kvk' => kvk,
          'kekv' => kekv,

          '_amount_type' => line[:amount_type]
      }

      %w(_year _month).each{ |key|
        item[key] = row[key].to_i unless row[key].nil?
      }

      item
    }.reject {|c| c.nil? || c['amount'] == 0 }
  end

end
