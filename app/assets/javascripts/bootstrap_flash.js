function show_bootstrap_flash(message,msg_class){
    $('.bootstrap_flash').html('');
    var notice_div = $('<div></div>');
    notice_div.addClass('alert fade in alert-' + msg_class + ' alert-dismissable')
    var button_div = $('<button aria-hidden="true" class="close" data-dismiss="alert" type="button">×</button>');
    notice_div.append(button_div);
    notice_div.append(message);
    $('.bootstrap_flash').append(notice_div);
    $('.bootstrap_flash').show();
    setTimeout(function(){
        // $('.bootstrap_flash').html('');
    },5000);
}