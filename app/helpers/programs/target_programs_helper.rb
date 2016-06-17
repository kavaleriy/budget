module Programs::TargetProgramsHelper
  def get_main_programs
    Programs::TargetProgram.get_main_programs
  end
end
