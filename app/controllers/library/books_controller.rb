module Library
  class BooksController < ApplicationController
    def index
      @library_books = Library::Book.all

      respond_to do |format|
        format.js
        format.html
      end
    end

    def new
      @library_book = Library::Book.new
    end

    def create
      @book = Book.new(library_book_params)

      respond_to do |format|
        if @book.save
          format.html { redirect_to @book, notice: 'User was successfully created.' }
          format.json { render action: 'show', status: :created, location: @book }
        else
          format.html { render action: 'new' }
          format.json { render json: @book.errors, status: :unprocessable_entity }
        end
      end
    end

    def show
      @library_book = Library::Book.find(params[:id])
    end

    private

    def library_book_params
      params.require(:library_book).permit(:category_id, :title, :branch, :town, :town_id, :description, :year, :yearFrom, :yearTo, :locked, :sort, :direction)
    end
  end
end

