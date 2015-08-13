module Documentation::DocumentsHelper
  def years(yearFrom, yearTo)
    years = [yearFrom]
    years << yearTo unless yearFrom == yearTo
    yearFrom == yearTo || !yearTo ? years.join('') : years.join(' - ')
  end
end
