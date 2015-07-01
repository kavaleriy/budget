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
    text = divide(text);
    s.text({text: text})
        .attr({
            'class': 'pie_center_text',
            'text-anchor': 'middle',
            'fill': options.fill,
            'fill-opacity': 0,
            'font-weight': options['font-weight'] || 'normal',
            'font-size': options['font-size'] || '0.8em'
        })
        .selectAll("tspan").forEach(function(tspan, i){
            var length = text.length;
            if(i < length/2) {
                tspan.attr({x: 0, y: -25*(length/2 - i) + 25});
            } else {
                tspan.attr({x: 0, y: 25*(i - length/2) + 25});
            }
        });
    s.selectAll('text').animate({'fill-opacity': 1, 'stroke-width': 1}, 5000, mina.elastic);
}

function truncate(text) {
    if(text.length > 20) {
        text = text.substr(0, 17) + '...';
    }
    return text;
}

function divide(text) {
    var txt = [];
    txt.push(text[0]);
    var words = text[1].split(" ");
    var tspan = words[0];
    for(var i = 0; i < words.length; i++) {
        if(words[i+1] && (tspan.length + words[i+1].length)<20) {
            tspan += " " + words[i+1];
        } else {
            txt.push(tspan);
            tspan = words[i+1];
        }
    }
    return txt;
}
