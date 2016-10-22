function aMapEmbedCode() {

    var el_id, width, height, src, k,
        min_width, min_height,
        max_width, max_height;

    function reset() {
        $(el_id + ' .frame_url').val("<iframe width=" + width + " height=" + height + " src='" + src + "'></iframe>");
    }

    return {
        initialize: function(options) {
            width = options.width;
            min_width = width - 300;
            max_width = width + 300;
            height = options.height;
            min_height = height - 300;
            max_height = height + 300;
            el_id = options.el_id;
            src = options.src;
            k = width/height;

            reset();

            $(el_id + ' .embed_btn').find('[data-toggle="popover"]').popover({
                html: true,
                placement : 'top',
                title: I18n.t('embed'),
                content: function() {
                    var content = "";
                    $(el_id + ' .frame_url').val("<iframe width=" + width + " height=" + height + " src='" + src + "'></iframe>");
                    return $(el_id + ' .form-horizontal');
                }
            })

            // hide popover if click outside
            $('body').on('click', function (e) {
                $('[data-toggle="popover"]').each(function () {
                    //console.log(1);
                    //the 'is' for buttons that trigger popups
                    //the 'has' for icons within a button that triggers a popup
                    if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
                        $(this).popover('hide');
                    }
                });
            });

            $(document.body).on('shown.bs.popover', function () {
                $(el_id + ' .iframe_size_select').change(function(e) {
                    var option = $(this).find(":selected").val();
                    if(option == "other" && $('.iframe_other_size').text() == "") {
                        $(el_id + ' .iframe_other_size').html("<input autofocus type=\"number\" min=\"100\" max=\"1000\" step=\"1\" name=\"width\" placeholder=\"width\"'></input> X \
                                                         <input type=\"number\" min=\"100\" max=\"1000\" step=\"1\" name=\"height\" placeholder=\"height\"'></input> px");
                    } else if (option != "other") {
                        $(el_id + ' .iframe_other_size').html('');
                        var size = $(this).find(":selected").text().split("x");
                        var width = size[0];
                        var height = size[1];
                        $(el_id + ' input').val("<iframe width='" + width + "' height='" + height + "' src='" + src + "'></iframe>");
                    }
                })

            });

        },
        set_iframe: function(new_src) {
            src = new_src;
            reset();
            $(document.body).on('shown.bs.popover', function () {
                reset();
            })
        }
    }
}