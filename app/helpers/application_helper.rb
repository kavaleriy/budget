module ApplicationHelper

  def is_current_year year
    year == @current_year
  end

  def format_date(date)
    date.strftime("%d.%m.%Y") if date.present?
  end

 def hexToRgb(color = "#ffffff")
  a = ( color.match /#(..?)(..?)(..?)/ )[1..3]
  a.map!{ |x| x + x } if color.size == 4
  "#{a[0].hex},#{a[1].hex},#{a[2].hex}"
 end

 def sortable(column, title = nil)
  title ||= column.titleize
  css_class = column == sort_column ? "current #{sort_direction}" : nil
  direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"
  link_to title, {:sort => column, :direction => direction}, {:class => css_class}
 end

 def get_file_type_icon(file_name)
   case File.extname(file_name).upcase
    when '.XLS', '.XLSX'
     'fa-file-excel-o'
    when '.DOC', '.DOCX', '.RTF'
     'fa-file-word-o'
    when '.XLS', '.XLSX'
     'fa-file-excel-o'
    when '.PPT', '.PPTX'
     'fa-file-powerpoint-o'
    when '.TXT'
     'fa-file-text-o'
    when '.PDF'
     'fa-file-pdf-o'
    when '.ZIP', '.RAR'
     'fa-file-pdf-o'
    else
     'fa-download'
   end

  end


  def get_calendars
    Calendar.visible_to(current_user,params[:locale])
    # calendars = if current_user.nil?
    #   Calendar.where(:author => nil)
    # elsif current_user.has_role? :admin
    #   Calendar.all
    # else
    #   Calendar.where(:author => nil) + Calendar.any_of({:author => current_user.email},{:town => current_user.town})
    # end
    #
    # calendars || []
  end


  def date_dmY(date)
    if date.nil?
      ''
    else
      date.strftime('%d-%m-%Y')
    end
  end

  def undp_colors_list
    [nil] + %w(
#8dd3c7 #ffffb3 #bebada #fb8072 #ffffff #80b1d3 #fdb462 #b3de69 #fccde5 #d9d9d9 #bc80bd #ccebc5 #ffed6f
#CCCCCC
#BBBBBB
#55bbff
#003366
#0055aa
#999999
#333333
#0b387c
#5a90Da
#a8bccc
#0088ff
#1E427E
#D5EDFB
#404040
#444444
#666666
#abc4bf
#edf4fe
#66c2ff
#557799
#434C55
#555555
#265f91
#ffffcc #ffeda0 #fed976 #feb24c #fd8d3c #fc4e2a #e31a1c #bd0026
)
  end

  def text_colors_list
    [nil] + %w(#8dd3c7 #ffffb3 #bebada #fb8072 #ffffff #80b1d3 #fdb462 #b3de69 #fccde5 #d9d9d9 #bc80bd #ccebc5 #ffed6f)
  end

  def get_bg_colors_list(type,holder = nil)
    colors = []
    case type
      when CalendarAction::ACTION_TYPE_FOLDING
        then colors += %w(#FF0000  #EF827F #CC5A59 #FC403F #DC143B #FE0034 #E0517C)
      when CalendarAction::ACTION_TYPE_ANALYSIS
        then colors += %w(#0000FF #012E4D #073082 #34489E #284DB7 #0091B2 #001AD1)
      when CalendarAction::ACTION_TYPE_EXECUTION
        then colors += %w(#008800 #64FE02 #5E9F32 #34CA21 #00A86B #167145 #00A900)
      when CalendarAction::ACTION_TYPE_DISCUSSION
        then colors += %w(#FF5D00 #EA7501 #FF7518 #FF8800 #FFA500 #FFA500 #FF8400)
    end

    # if holder.nil? or holder == 1
    #   colors += %w(#ffffcc #ffeda0 #fed976 #feb24c #fd8d3c #fc4e2a #e31a1c #bd0026 red)
    # end
    # if holder.nil? or holder == 2
    #   colors += %w(#f7fcf0 #e0f3db #ccebc5 #a8ddb5 #7bccc4 #4eb3d3 #2b8cbe #0868ac #084081)
    # end
    colors
  end


  def fa_icon_list
    [nil] + %w(
     fa-adjust
     fa-anchor
     fa-archive
     fa-arrows
     fa-arrows-h
     fa-arrows-v
     fa-asterisk
     fa-automobile
     fa-ban
     fa-bank
     fa-bar-chart-o
     fa-barcode
     fa-bars
     fa-beer
     fa-bell
     fa-bell-o
     fa-bolt
     fa-bomb
     fa-book
     fa-bookmark
     fa-bookmark-o
     fa-briefcase
     fa-bug
     fa-building
     fa-building-o
     fa-bullhorn
     fa-bullseye
     fa-cab
     fa-calendar
     fa-calendar-o
     fa-camera
     fa-camera-retro
     fa-car
     fa-caret-square-o-down
     fa-caret-square-o-left
     fa-caret-square-o-right
     fa-caret-square-o-up
     fa-certificate
     fa-check
     fa-check-circle
     fa-check-circle-o
     fa-check-square
     fa-check-square-o
     fa-child
     fa-circle
     fa-circle-o
     fa-circle-o-notch
     fa-circle-thin
     fa-clock-o
     fa-cloud
     fa-cloud-download
     fa-cloud-upload
     fa-code
     fa-code-fork
     fa-coffee
     fa-cog
     fa-cogs
     fa-comment
     fa-comment-o
     fa-comments
     fa-comments-o
     fa-compass
     fa-credit-card
     fa-crop
     fa-crosshairs
     fa-cube
     fa-cubes
     fa-cutlery
     fa-dashboard
     fa-database
     fa-desktop
     fa-dot-circle-o
     fa-download
     fa-edit
     fa-ellipsis-h
     fa-ellipsis-v
     fa-envelope
     fa-envelope-o
     fa-envelope-square
     fa-eraser
     fa-exchange
     fa-exclamation
     fa-exclamation-circle
     fa-exclamation-triangle
     fa-external-link
     fa-external-link-square
     fa-eye
     fa-eye-slash
     fa-fax
     fa-female
     fa-fighter-jet
     fa-file-archive-o
     fa-file-audio-o
     fa-file-code-o
     fa-file-excel-o
     fa-file-image-o
     fa-file-movie-o
     fa-file-pdf-o
     fa-file-photo-o
     fa-file-picture-o
     fa-file-powerpoint-o
     fa-file-sound-o
     fa-file-video-o
     fa-file-word-o
     fa-file-zip-o
     fa-film
     fa-filter
     fa-fire
     fa-fire-extinguisher
     fa-flag
     fa-flag-checkered
     fa-flag-o
     fa-flash
     fa-flask
     fa-folder
     fa-folder-o
     fa-folder-open
     fa-folder-open-o
     fa-frown-o
     fa-gamepad
     fa-gavel
     fa-gear
     fa-gears
     fa-gift
     fa-glass
     fa-globe
     fa-graduation-cap
     fa-group
     fa-hdd-o
     fa-headphones
     fa-heart
     fa-heart-o
     fa-history
     fa-home
     fa-image
     fa-inbox
     fa-info
     fa-info-circle
     fa-institution
     fa-key
     fa-keyboard-o
     fa-language
     fa-laptop
     fa-leaf
     fa-legal
     fa-lemon-o
     fa-level-down
     fa-level-up
     fa-life-bouy
     fa-life-ring
     fa-life-saver
     fa-lightbulb-o
     fa-location-arrow
     fa-lock
     fa-magic
     fa-magnet
     fa-mail-forward
     fa-mail-reply
     fa-mail-reply-all
     fa-male
     fa-map-marker
     fa-meh-o
     fa-microphone
     fa-microphone-slash
     fa-minus
     fa-minus-circle
     fa-minus-square
     fa-minus-square-o
     fa-mobile
     fa-mobile-phone
     fa-money
     fa-moon-o
     fa-mortar-board
     fa-music
     fa-navicon
     fa-paper-plane
     fa-paper-plane-o
     fa-paw
     fa-pencil
     fa-pencil-square
     fa-pencil-square-o
     fa-phone
     fa-phone-square
     fa-photo
     fa-picture-o
     fa-plane
     fa-plus
     fa-plus-circle
     fa-plus-square
     fa-plus-square-o
     fa-power-off
     fa-print
     fa-puzzle-piece
     fa-qrcode
     fa-question
     fa-question-circle
     fa-quote-left
     fa-quote-right
     fa-random
     fa-recycle
     fa-refresh
     fa-reorder
     fa-reply
     fa-reply-all
     fa-retweet
     fa-road
     fa-rocket
     fa-rss
     fa-rss-square
     fa-search
     fa-search-minus
     fa-search-plus
     fa-send
     fa-send-o
     fa-share
     fa-share-alt
     fa-share-alt-square
     fa-share-square
     fa-share-square-o
     fa-shield
     fa-shopping-cart
     fa-sign-in
     fa-sign-out
     fa-signal
     fa-sitemap
     fa-sliders
     fa-smile-o
     fa-sort
     fa-sort-alpha-asc
     fa-sort-alpha-desc
     fa-sort-amount-asc
     fa-sort-amount-desc
     fa-sort-asc
     fa-sort-desc
     fa-sort-down
     fa-sort-numeric-asc
     fa-sort-numeric-desc
     fa-sort-up
     fa-space-shuttle
     fa-spinner
     fa-spoon
     fa-square
     fa-square-o
     fa-star
     fa-star-half
     fa-star-half-empty
     fa-star-half-full
     fa-star-half-o
     fa-star-o
     fa-suitcase
     fa-sun-o
     fa-support
     fa-tablet
     fa-tachometer
     fa-tag
     fa-tags
     fa-tasks
     fa-taxi
     fa-terminal
     fa-thumb-tack
     fa-thumbs-down
     fa-thumbs-o-down
     fa-thumbs-o-up
     fa-thumbs-up
     fa-ticket
     fa-times
     fa-times-circle
     fa-times-circle-o
     fa-tint
     fa-toggle-down
     fa-toggle-left
     fa-toggle-right
     fa-toggle-up
     fa-trash-o
     fa-tree
     fa-trophy
     fa-truck
     fa-umbrella
     fa-university
     fa-unlock
     fa-unlock-alt
     fa-unsorted
     fa-upload
     fa-user
     fa-users
     fa-video-camera
     fa-volume-down
     fa-volume-off
     fa-volume-up
     fa-warning
     fa-wheelchair
     fa-wrench'
    )
  end

  def get_nav_link(menu_list)

    if menu_list.link.nil? || menu_list.link.empty?
      show_pages_path(menu_list.alias)
    else
      menu_list.link + "?locale=" + I18n.locale.to_s
    end
  end

 def check_admin
   current_user && current_user.admin?
 end

end
