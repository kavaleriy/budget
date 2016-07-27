module Library::BooksHelper
  def get_img book
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
end
