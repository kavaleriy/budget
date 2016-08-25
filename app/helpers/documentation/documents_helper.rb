module Documentation::DocumentsHelper
  def years(yearFrom, yearTo)

    # todo  --> delete after relize
    # years = [yearFrom]
    # years << yearTo unless yearFrom == yearTo
    # yearFrom == yearTo || !yearTo ? years.join('') : years.join(' - ')


    # check incoming data from DB for validness (should looks like year in 'xxxx' format, everything else accept like 'nil')
    # return data in different format depend on incoming data for more informative for user, for examples:
    #   in case:
    #      - no valid data - return '-'
    #      - receive only one valid 'year' - return 'from some year' or 'to some year' depend on incoming data
    #      - receive both valid 'years' - return interval looks like 'year - year'
    if yearFrom.nil? || yearFrom.to_s.size != 4
      yearTo.to_s.size == 4 ? t('.to') + ' ' + yearTo.to_s : '-'
    elsif yearTo.nil? || yearTo.to_s.size != 4
      yearFrom.to_s.size == 4 ? t('.from') + ' ' + yearFrom.to_s : '-'
    else
      yearFrom.to_s + ' - ' + yearTo.to_s
    end
  end

  def get_beautiful_doc_title(title)
    # cut extension in title and replace underline to space
    title.split('.').first.gsub('_', ' ')
  end

  def get_image_path_by_doc_type(doc_file)
    # set default path to folder icons
    default_path = 'new_design/icons/'
    # set icon to file by extension
    image_path = case doc_file.file.extension.downcase
    # check file extensions (ext)
                   # portable document format
                   when 'pdf'
                    'file-pdf.svg'
                   # MS spreadsheet
                   when 'xls', 'xlsx', 'xlsm', 'xlsb'
                    'file-exel.svg'
                   # MS word processing documents
                   when 'doc', 'docx'
                    'file-word.svg'
                   # famous arhive formats
                   when 'rar', 'zip', '7z', 'tar', 'gz', 'par'
                     'file-rar.svg'
                   # all another formats
                   else
                     'no-image.svg'
    end
    default_path.concat(image_path)
  end

  # todo --> delete after relize
  # def truncate_title(string, length = 25)
  #   string.size > length ? [string[0,15], string[-3,3]].join('....') : string unless string.nil?
  # end
end
