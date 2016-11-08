# Be sure to restart your server when you modify this file.
Mime::Type.register_alias "text/excel", :xls
Mime::Type.register_alias "text/excel", :xlsx

if Mime::Type.lookup_by_extension(:pdf) != 'application/pdf'
  Mime::Type.register('application/pdf', :pdf)
end
# Add indicator_file mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
