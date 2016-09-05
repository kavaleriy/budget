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

  def book_filters
    book_filters = []
    # all books
    book_filters.push({title: "Усі книги", url: library_books_path})
    # books without category
    categories_nil = Library::Book.pluck(category: nil).uniq
    categories = Library::Book.pluck(:category).uniq.compact.sort   # .compact - delete all nil elements
    if categories[0] == '' || categories_nil[0] == nil
      book_filters.push({title: "Без категорії", url: library_books_path(category_empty: "empty")})
    end
    # books with category
    categories.each do |category|
      if category != ''
        book_filters.push({title: category, url: library_books_path(category: category)})
      end
    end
    book_filters
  end
end
