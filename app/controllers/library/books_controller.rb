module Library
  class BooksController < ApplicationController
    layout 'application_admin'

    helper_method :sort_column, :sort_direction

    def index
      @library_books = Library::Book.order(sort_column + " " + sort_direction).page(params[:page]).per(10)

      respond_to do |format|
        format.js
        format.html
      end
    end

    def new
      # @find_categories = Library::Book.pluck(:category).uniq
      @library_book = Library::Book.new
      # respond_to do |format|
      #   format.js { @categories = @find_categories }
      #   format.html
      # end
    end

    def edit
      @library_book = Library::Book.find(params[:id])
    end

    def create
      @library_book = Book.new(library_book_params)
      @library_book.owner = current_user

      respond_to do |format|
        if @library_book.save
          format.html { redirect_to library_books_url, notice: 'Book was successfully created.' }
          # format.html { redirect_to @library_book, notice: 'Book was successfully created.' }
          # format.json { render action: 'show', status: :created, location: @library_book }  #, status: :created, location: @book
        else
          format.html { render action: 'new' }
          format.json { render json: @library_book.errors, status: :unprocessable_entity }
        end
      end
    end

    def show
      @library_book = Library::Book.find(params[:id])
    end

    def update
      @library_book = Library::Book.find(params[:id])

      unless params[:library_book][:title].blank?
        unless params[:library_book][:book_file].blank?
          @library_book.remove_book_file!
        end
      end

      unless params[:library_book][:title].blank?
        unless params[:library_book][:book_img].blank?
          @library_book.remove_book_img!
        end
      end

      respond_to do |format|
        if @library_book.update(library_book_params)
          format.html { redirect_to library_books_url, notice: 'Book was successfully updated.' }
          # format.html { redirect_to @library_book, notice: 'Book was successfully updated.' }
          # format.json { render action: 'show', status: :created, location: @library_book }
        else
          format.html { render action: 'edit' }
          format.json { render json: @library_book.errors, status: :unprocessable_entity }
        end
      end
    end


    def destroy
      @library_book = Library::Book.find(params[:id])
      @library_book.destroy
      redirect_to library_book_path
    end

    private

    def sort_column
      Library::Book.fields.keys.include?(params[:sort]) ? params[:sort] : "updated_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def library_book_params
      params.require(:library_book).permit(:category, :title, :author, :year_publication, :description, :book_url, :book_file, :book_img )
    end
  end
end

