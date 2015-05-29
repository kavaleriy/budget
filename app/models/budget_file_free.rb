class BudgetFileFree < BudgetFile

  protected

  def readline row
    amount_key = row.keys.last
    amount = row[amount_key].to_f
    return if amount.nil? || amount == 0

    line = {
        'amount' => amount,
    }

    row.keys.reject{|k| k == amount_key}.each {|r|
      val = row[r].to_s.split('.')[0]
      line[r] = val
    }

    line
  end

end
