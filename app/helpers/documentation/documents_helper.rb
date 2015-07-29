module Documentation::DocumentsHelper
  def years(yearFrom, yearTo)
    years = [yearFrom]
    years << yearTo unless yearFrom == yearTo
    years.join(' - ')
  end
end
