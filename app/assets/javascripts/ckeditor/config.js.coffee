CKEDITOR.editorConfig = (config) ->

  config.filebrowserBrowseUrl = "/ckeditor/attachment_files"
  config.filebrowserFlashBrowseUrl = "/ckeditor/attachment_files"
  config.filebrowserFlashUploadUrl = "/ckeditor/attachment_files"
  config.filebrowserImageBrowseLinkUrl = "/ckeditor/pictures"
  config.filebrowserImageBrowseUrl = "/ckeditor/pictures"
  config.filebrowserImageUploadUrl = "/ckeditor/pictures"
  config.filebrowserUploadUrl = "/ckeditor/attachment_files"

  config.language = 'uk'
  config.toolbar_Pure = [
    { name: 'document',    items: [ 'Source','-','Save','NewPage','DocProps','Preview','Print','-','Templates' ] },
    { name: 'clipboard',   items: [ 'Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo' ] },
    { name: 'editing',     items: [ 'Find','Replace','-','SelectAll','-','SpellChecker', 'Scayt' ] },
    { name: 'tools',       items: [ 'Maximize', 'ShowBlocks','-','About' ] }
    '/',
    { name: 'basicstyles', items: [ 'Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat' ] },
    { name: 'paragraph',   items: [ 'NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','CreateDiv','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock','-','BidiLtr','BidiRtl' ] },
    { name: 'links',       items: [ 'Link','Unlink','Anchor' ] },
    '/',
    { name: 'styles',      items: [ 'Styles','Format','Font','FontSize' ] },
    { name: 'colors',      items: [ 'TextColor','BGColor' ] },
    { name: 'insert',      items: [ 'Image','Flash','Table','HorizontalRule','Smiley','SpecialChar','PageBreak' ] },
  ]
  config.allowedContent = true
  config.extraAllowedContent = 'b i span'
  config.toolbar = 'Pure'
  true
