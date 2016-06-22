module Programs::TargetProgramsHelper
  def get_main_programs
    Programs::TargetProgram.get_main_programs
  end

  def get_grouped_indicators(indicators)
    group_indicators = indicators.group_by{|f| f.group}
    group_indicators.transform_keys{|key|set_indicator_group_name(key)}
  end

  def set_indicator_group_name(key)
    case key.to_i
      when Programs::Indicator::EXPENSES_TYPE then 'expense'
      when Programs::Indicator::PRODUCT_TYPE then 'product'
      when Programs::Indicator::EFECTIVE_TYPE then 'Efective'
      when Programs::Indicator::QUALITY_TYPE then 'quality'
      else
        'other'
    end
  end
end
