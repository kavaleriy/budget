module Library::BooksHelper
  def get_book_img book
    if book.book_img?
      image_tag(book.book_img.thumb)
    else
      image_tag("book_off.png")
    end
  end

  def get_url book
    if book.book_file?
      book.book_file.url
    elsif book.book_url?
      book.book_url
    end
  end

  def access_user book
    unless current_user.nil?
     current_user.id == book.owner_id || current_user.has_role?(:admin)
   end
  end

  # Generate list filters for books
  def book_filters(locale)
    book_filters = []
    title_all_books = t('library.books.index.all_books')
    title_without_category = t('library.books.index.without_category')

    # filter all books
    book_filters.push({title: title_all_books, url: library_books_path})
    # filter books without category
    books_by_locale = Library::Book.get_books_by_locale(locale)
    categories_nil = books_by_locale.pluck(category: nil).uniq
    categories = books_by_locale.pluck(:category).uniq.compact.sort   # .compact - delete all nil elements
    if categories[0] == '' || categories_nil[0] == nil
      book_filters.push({title: title_without_category, url: library_books_path(category_empty: "empty")})
    end
    # filters books with category
    categories.each do |category|
      if category != ''
        book_filters.push({title: category, url: library_books_path(category: category)})
      end
    end
    book_filters
  end
end
