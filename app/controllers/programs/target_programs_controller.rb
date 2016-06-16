class Programs::TargetProgramsController < ApplicationController
  layout 'application_admin', except: [:index, :show]

  before_action :authenticate_user!, only: [:new, :edit]
  # load_and_authorize_resource

  # GET /programs/target_programs
  # GET /programs/target_programs.json


  def stub_data
    @years = ['2015', '2016', 2017, 2018]
    @year = Date.today.year.to_s
    # @programs = [
    #     { id: '9123', title: 'Заходи  у сфері траспортного сполучення', years:
    #         {
    #             2015 => { plan: 21876, fact: 4672.33, perc: 26.53},
    #             2016 => { plan: 32367, fact: 12367.33, perc: 86.53}
    #         },
    #       sub_programs: [
    #           { id: '91231', title: 'Підпрограмма 1 - Заходи  у сфері траспортного сполучення', years:
    #               {
    #                   2017 => { plan: 32234, fact: 3782.33, perc: 78.53},
    #                   2016 => { plan: 12967, fact: 12367.33, perc: 92.53}
    #               }
    #           },
    #           { id: '91232', title: 'Підпрограмма 2 - Заходи  у сфері траспортного сполучення', years:
    #               {
    #                   2016 => { plan: 92833, fact: 33367.33, perc: 34.53},
    #                   2017 => { plan: 32367, fact: 12367.33, perc: 86.53}
    #               }
    #           },
    #       ]
    #     },
    #     { id: '9124', title: 'Заходи державної політики з питань молоді', years:
    #         {
    #             2016 => { plan: 32234, fact: 3782.33, perc: 78.53},
    #             2017 => { plan: 12967, fact: 12367.33, perc: 92.53}
    #         },
    #         sub_programs: [
    #             { id: '91231', title: 'Підпрограмма 1 - Заходи  у сфері траспортного сполучення', years:
    #                 {
    #                     2017 => { plan: 32234, fact: 3782.33, perc: 78.53},
    #                     2016 => { plan: 12967, fact: 12367.33, perc: 92.53}
    #                 }
    #             },
    #             { id: '91232', title: 'Підпрограмма 2 - Заходи  у сфері траспортного сполучення', years:
    #                 {
    #                     2016 => { plan: 92833, fact: 33367.33, perc: 34.53},
    #                     2017 => { plan: 32367, fact: 12367.33, perc: 86.53}
    #                 }
    #             },
    #         ]
    #     },
    #     { id: '9125', title: 'Заходи у сфері захисту населення і територій від надзвичайних ситуацій техногенного та природного характеру ', years:
    #         {
    #             2016 => { plan: 32234, fact: 3782.33, perc: 78.53},
    #             2018 => { plan: 12967, fact: 12367.33, perc: 92.53}
    #         }
    #     },
    #     { id: '9126', title: 'Благоустрій міст, сіл, селищ', years:
    #         {
    #             2016 => { plan: 92833, fact: 33367.33, perc: 34.53},
    #             2018 => { plan: 32367, fact: 12367.33, perc: 86.53}
    #         }
    #     },
    # ]
  end

  def index
    stub_data
    @programs = TargetedPrograms::Program.get_main_programs
  end

  def show
    stub_data
    @program = TargetedPrograms::Program.first
    # @program = @programs[0]
    #
    #
    # @program[:indicators] ||= [
    #   {
    #     title: 'Витрати',
    #       items: [
    #         { title: 'Індікатор витрат 1' },
    #         { title: 'Індікатор витрат 2' },
    #         { title: 'Індікатор витрат 3' },
    #       ]
    #   },
    #   {
    #       title: 'Продукт',
    #       items: [
    #         { title: 'Індікатор продукт 1' },
    #         { title: 'Індікатор продукт 2' },
    #       ]
    #   },
    #   {
    #       title: 'Єфективність',
    #       items: [
    #         { title: 'Індікатор єфективність 1' },
    #         { title: 'Індікатор єфективність 2' },
    #         { title: 'Індікатор єфективність 3' },
    #         { title: 'Індікатор єфективність 4' },
    #       ]
    #   },
    #   {
    #       title: 'Якість',
    #       items: [
    #         { title: 'Індікатор якість 1' },
    #         { title: 'Індікатор якість 2' },
    #         { title: 'Індікатор якість 3' },
    #         { title: 'Індікатор якість 4' },
    #         { title: 'Індікатор якість 5' },
    #         { title: 'Індікатор якість 6' },
    #         { title: 'Індікатор якість 7' },
    #         { title: 'Індікатор якість 8' },
    #       ]
    #   },
    # ]
  end


  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def programs_target_program_params
      params.require(:programs_target_program).permit(:id)
    end
end
