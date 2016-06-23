module Programs::TargetedProgramsHelper
  def get_main_programs
    Programs::TargetedProgram.get_main_programs
  end

  def calc_percentage(plan,fact)
    if fact.eql?(0)
      #Test some data
      22
    else
      ((fact.to_f/plan.to_f) * 100)
    end

  end


end
