function resizeNavbar(top){
    var headerHeigth = 70;
    var animateSpeed = 600;
        if (top > headerHeigth && !$('nav').hasClass('min')) {
            $('nav').addClass('min').stop().animate({height: '50px'},animateSpeed);
            $('ul.nav').stop().animate({padding: '0 auto auto auto'}, animateSpeed);
            $('div.logo-block').stop().animate({margin: '0'},animateSpeed);
            $('div.logo-block > img.logo').stop().animate({padding: '5px auto'},animateSpeed);
            $('div.logo-block a.logo-src > p.title').stop().animate({opacity: '0'},animateSpeed);
        } else if (top < headerHeigth){
            $('nav').removeClass('min', {duration:500}).stop().animate({height: '73px'},animateSpeed);
            $('ul.nav').stop().animate({padding: '23px auto auto auto'}, animateSpeed);
            $('div.logo-block').stop().animate({margin: '8px 0'},animateSpeed);
            $('div.logo-block > img.logo').stop().animate({padding: 'auto auto 8px auto'},animateSpeed);
            $('div.logo-block a.logo-src > p.title').queue(function () {
                $(this).stop().animate({opacity: '100'},animateSpeed);
                $(this).dequeue();
            });
        }
}