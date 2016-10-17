namespace :library_books do
  desc "Add locale field in books"
  task add_locale_field: :environment do
    Library::Book.where(locale: nil).update_all(locale: 'uk')
  end
end