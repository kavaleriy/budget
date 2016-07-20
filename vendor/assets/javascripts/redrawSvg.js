function redrawSvg(panel,canv) {

    var svgElements = $(panel).find('svg');
    //replace all svgs with a temp canvas
    
    svgElements.each(function () {
        var canvas, xml;
        // console.log($(this))
        // canvg doesn't cope very well with em font sizes so find the calculated size in pixels and replace it in the element.
        $.each($(this).find('[style*=em]'), function (index, el) {
            $(this).css('font-size', '10px');
        });
    
        canvas = document.createElement("canvas");
        canvas.className = "screenShotTempCanvas";
        //convert SVG into a XML string
        xml = (new XMLSerializer()).serializeToString(this);
    
        // Removing the name space as IE throws an error
        xml = xml.replace(/xmlns=\"http:\/\/www\.w3\.org\/2000\/svg\"/, '');
    
        //draw the SVG onto a canvas
        canvg(canvas, xml);
        $(canvas).insertAfter(this);
        //hide the SVG element
        $(this).attr('class', 'tempHide');
        $(this).hide();
    
    });
}

function showOriginalSvg(){
    $('.tempHide').show();
    $('.screenShotTempCanvas').hide();
}