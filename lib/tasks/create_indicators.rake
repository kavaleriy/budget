namespace :create_indicators do
  task remove_old_indicators: :environment do
    TargetedPrograms::Indicator.each { |indicator| indicator.destroy}
  end
  task create_indicators: :remove_old_indicators do
    indicators = [
        {
            title: 'Витрати',
            items: [
                { title: 'Індікатор витрат 1' },
                { title: 'Індікатор витрат 2' },
                { title: 'Індікатор витрат 3' },
            ]
        },
        {
            title: 'Продукт',
            items: [
                { title: 'Індікатор продукт 1' },
                { title: 'Індікатор продукт 2' },
            ]
        },
        {
            title: 'Єфективність',
            items: [
                { title: 'Індікатор єфективність 1' },
                { title: 'Індікатор єфективність 2' },
                { title: 'Індікатор єфективність 3' },
                { title: 'Індікатор єфективність 4' },
            ]
        },
        {
            title: 'Якість',
            items: [
                { title: 'Індікатор якість 1' },
                { title: 'Індікатор якість 2' },
                { title: 'Індікатор якість 3' },
                { title: 'Індікатор якість 4' },
                { title: 'Індікатор якість 5' },
                { title: 'Індікатор якість 6' },
                { title: 'Індікатор якість 7' },
                { title: 'Індікатор якість 8' },
            ]
        },
    ]
    indicators.each do |indicator|
      TargetedPrograms::Indicator.new({title: indicator[:title],items: indicator[:items],targeted_program: get_targeted_programs}).save!
    end
  end
  def get_targeted_programs
    TargetedPrograms::Program.where({title:'Заходи  у сфері траспортного сполучення'}).first
  end
end