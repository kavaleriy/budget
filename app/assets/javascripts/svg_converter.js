$(document).bind('page:change', function(e) {

    d3.select("#save").on("click", function(){

        //alert(d3.select("#chart").node().innerHTML);

        var html = d3.select("svg")
            .attr("version", 1.1)
            .attr("xmlns", "http://www.w3.org/2000/svg")
            .node().parentNode.innerHTML;

        //console.log(html);
        var imgsrc = 'data:image/svg+xml;base64,'+ btoa(html);
        var img = '<img src="'+imgsrc+'">';

        var canvas = document.querySelector("canvas"),
            context = canvas.getContext("2d");

        var image = new Image;
        image.src = imgsrc;
        image.onload = function() {
            context.drawImage(image, 0, 0);

            var canvasdata = canvas.toDataURL("image/png");

            var pngimg = '<img src="' + canvasdata + '">';

            var a = document.createElement("a");
            a.download = "sample.png";
            a.href = canvasdata;
            a.click();
        };

    });

})