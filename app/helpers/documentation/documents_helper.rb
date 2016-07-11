module Documentation::DocumentsHelper
  def years(yearFrom, yearTo)
    years = [yearFrom]
    years << yearTo unless yearFrom == yearTo
    yearFrom == yearTo || !yearTo ? years.join('') : years.join(' - ')
  end

  def get_beautiful_doc_title(title)
    # cut extension in title and replace underline to space
    title.split('.').first.gsub!('_', ' ')
  end

  def get_image_path_by_doc_type(doc_file)
    default_path = 'new_design/icons/'
    image_path = case doc_file.file.extension
                   when 'pdf'
                    'file-pdf.svg'
                   when 'xls' || 'xlsx'
                    'file-exel.svg'
                   when 'doc'
                    'file-word.svg'
                   when 'rar'
                     'file-rar.svg'
                   else
                     'no_image.svg'
    end
    default_path.concat(image_path)
  end
end
