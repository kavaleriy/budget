namespace :create_targeted_programs do

  task remove_old_programs: :environment do
    Programs::TargetedProgram.each { |program| program.destroy }
  end
  task create_transport_program: :remove_old_programs do
    transport_program = Programs::TargetedProgram.new({title:'Заходи  у сфері траспортного сполучення',
                                                       years: {
                                                 2015 => {plan: 21876, fact: 4672.33, perc: 26.53},
                                                 2016 => { plan: 32367, fact: 12367.33, perc: 86.53}
                                              },
                                                       # indicators: get_indicators
                                             })
    transport_program.save!
    transport_subPrograms =[
        { title: 'Підпрограмма 1 - Заходи  у сфері траспортного сполучення', years:
            {
                2017 => { plan: 32234, fact: 3782.33, perc: 78.53},
                2016 => { plan: 12967, fact: 12367.33, perc: 92.53}
            }
        },
        { title: 'Підпрограмма 2 - Заходи  у сфері траспортного сполучення', years:
            {
                2016 => { plan: 92833, fact: 33367.33, perc: 34.53},
                2017 => { plan: 32367, fact: 12367.33, perc: 86.53}
            }
        },
    ]

    transport_subPrograms.each do |subprogram|
      new_subprogram = Programs::TargetedProgram.new({title: subprogram[:title], years: subprogram[:years], p_id: transport_program.id})
      new_subprogram.save!
    end
  end
  task create_young_program: :create_transport_program do
    young_program = Programs::TargetedProgram.new({title:'Заходи державної політики з питань молоді',
                                                   years:{
                                             2017 => { plan: 32234, fact: 3782.33, perc: 78.53},
                                             2016 => { plan: 12967, fact: 12367.33, perc: 92.53}
                                          },
                                                   # indicators: get_indicators
                                         })
    young_program.save!
    young_subprogram = [
                  { id: '91231', title: 'Підпрограмма 1 - Заходи  у сфері траспортного сполучення', years:
                      {
                          2017 => { plan: 32234, fact: 3782.33, perc: 78.53},
                          2016 => { plan: 12967, fact: 12367.33, perc: 92.53}
                      }
                  },
                  { id: '91232', title: 'Підпрограмма 2 - Заходи  у сфері траспортного сполучення', years:
                      {
                          2016 => { plan: 92833, fact: 33367.33, perc: 34.53},
                          2017 => { plan: 32367, fact: 12367.33, perc: 86.53}
                      }
                  },
              ]
    young_subprogram.each do |subprogram|
      new_subprogram = Programs::TargetedProgram.new({title: subprogram[:title], years: subprogram[:years], p_id: young_program.id})
      new_subprogram.save!
    end
  end

  task create_extraordinary_program: :create_young_program do
    extraordinary_program = Programs::TargetedProgram.new({title: 'Заходи у сфері захисту населення і територій від надзвичайних ситуацій техногенного та природного характеру',
                                                           years: {
                                                     2016 => { plan: 32234, fact: 3782.33, perc: 78.53},
                                                     2018 => { plan: 12967, fact: 12367.33, perc: 92.53}
                                                  },
                                                           # indicators: get_indicators
                                                 })
    extraordinary_program.save!
  end

  task create_improvement_program: :create_extraordinary_program do
    improvement_program = Programs::TargetedProgram.new({title: 'Благоустрій міст, сіл, селищ',
                                                         years: {
                                                  2016 => { plan: 92833, fact: 33367.33, perc: 34.53},
                                                  2018 => { plan: 32367, fact: 12367.33, perc: 86.53}
                                                },
                                                         # indicators: get_indicators
                                               })
    improvement_program.save!
  end
end