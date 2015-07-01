function path_animation(status, el) {
    switch(status) {
        case 'start':
            var s = Snap.select('#chart svg g');
            s.append(el); // to move current path to the front
            var pathEl = Snap.select('#' + $(el).attr('id'));
            $(el).css("stroke", $(el).css('fill'));
            $(el).data('fill-opacity', $(el).css('fill-opacity'));
            pathEl.stop().animate( { 'stroke-width': 15, 'fill-opacity': '0.8', 'stroke-opacity': '0.8' }, 1000, mina.elastic);
            break;
        case 'stop':
            var pathEl = Snap.select('#' + $(el).attr('id'));
            pathEl.stop().animate( { 'stroke-width': 1, 'fill-opacity': $(el).data('fill-opacity'), 'stroke-opacity': '1' }, 1000, mina.elastic);
            $(el).css("stroke", "#ffffff");
            break;
    }
}

function text_animation(text, options) {
    $('#chart svg g text').remove();
    var s = Snap.select('#chart svg g');
    var a = 0;
    for(var i = 0; i < text.length; i++) {
        var txt = s.text(0,a + 'em',truncate(text[i])); // to move text to the front
        txt.attr({
            'text-anchor': 'middle',
            'fill': options.fill,
            'fill-opacity': 0,
            'font-weight': options['font-weight'] || 'normal',
            'font-size': options['font-size'] || '0.8em'
        });
        a += 1.5;
    }
    s.selectAll('text').animate({'fill-opacity': 1, 'stroke-width': 1}, 5000, mina.elastic);
}

function truncate(text) {
    if(text.length > 20) {
        text = text.substr(0, 17) + '...';
    }
    return text;
}
