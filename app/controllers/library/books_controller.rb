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

    def edit
      @library_book = Library::Book.find(params[:id])
    end

    def create
      @book = Book.new(library_book_params)

      respond_to do |format|
        if @book.save
          format.html { redirect_to @book, notice: 'Book was successfully created.' }
          format.json { render action: 'show', status: :created, location: @book }  #, status: :created, location: @book
        else
          format.html { render action: 'new' }
          format.json { render json: @book.errors, status: :unprocessable_entity }
        end
      end
    end

    def show
      @library_book = Library::Book.find(params[:id])
    end

    def update
      @book = Library::Book.find(params[:id])

      respond_to do |format|
        if @book.update(library_book_params)
          format.html { redirect_to @book, notice: 'Book was successfully updated.' }
          format.json { render action: 'show', status: :created, location: @book }
        else
          format.html { render action: 'edit' }
          format.json { render json: @book.errors, status: :unprocessable_entity }
        end
      end
    end


    def destroy
      @library_book = Library::Book.find(params[:id])
      @library_book.destroy

      redirect_to library_book_path
    end

    private

    def library_book_params
      params.require(:library_book).permit( :title, :description, :doc_file)
    end
  end
end

