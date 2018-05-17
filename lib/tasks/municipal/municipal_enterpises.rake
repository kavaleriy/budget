namespace :enterprises do
  desc "set enterprises statuses"
  task set_statuses: :environment do
    StatusCode::SetStatus.all_enterprises
  end
end