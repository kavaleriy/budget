module Municipal::PublicEnterprisesHelper
  def title_for_code(code, title)
    # hide code for analysis codes title
    code.first.eql?('7') ? title : "#{code} #{title}"
  end
end
