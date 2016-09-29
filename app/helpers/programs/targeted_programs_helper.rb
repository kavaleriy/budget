module Programs::TargetedProgramsHelper

  def get_main_programs
    Programs::TargetedProgram.get_main_programs
  end

  # get plan & fact as FLOAT
  # return zero if fact = 0.0
  # or
  # part from 100 percent
  def calc_percentage(plan, fact)
    fact.eql?(0.0) ? 0.0 : ((fact.to_f/plan.to_f) * 100)
  end

end
