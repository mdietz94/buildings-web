function DetailView(){
	// just a template empty constructor
}

DetailView.prototype.load = function(id){
	this.id = id
	// in case we are using a placeholder image
	var src = $("#" + id + ' img').attr('src')
	$('#bg').css('background-image', 'url(' + src + ')')
	$("#building-detail").show()
	$(this).trigger('show')
	var bldg = new Building(id)
	bldg.load()
	$.getJSON("/num_images/" + id, function(r){
		bldg.numImages = r['images']
	})
	$(document).one('ajaxStop', function(){
		content = "<div class='detail-name'>" + bldg.name + "</div>"
			+ "<div class='detail-architect'>" + bldg.architect + "</div>"
			+ "<div class='detail-location'>" + bldg.city + ", " + bldg.state + "</div>"
			+ "<div class='detail-description'>" + bldg.description + "</div>"
			+ "<div id='galleria'>"
		for (var i=0;i<bldg.numImages;i++) {
			content += "<img src='/static/images/bldg" + bldg.id + "x" + i + ".jpg' alt='Main Image'>"
		}
		content += "<img src='http://maps.googleapis.com/maps/api/streetview?size=600x300&location=" + bldg.latitude
			+ "," + bldg.longitude + "&sensor=false' alt='Google StreetView'></div>"
			+ "<div class='detail-map'><img src='http://maps.googleapis.com/maps/api/staticmap?markers=size:mid%7Ccolor:red%7C"
			+ bldg.latitude + "," + bldg.longitude + "&zoom=13&size=200x200&sensor=false&visual_refresh=true' alt='Google Maps'></div>"
			+ "</div>"
			$("#building-detail").html(content)
		Galleria.loadTheme('/static/js/lib/galleria/themes/classic/galleria.classic.min.js')
		Galleria.run("#galleria")
	})
	$(window).on('mousemove', null, this, this.onMouseMove)
	$("#building-detail").removeClass('shrink')
}

DetailView.prototype.unload = function(){
	$("#building-detail").hide()
	$(this).trigger('hide')
}

DetailView.prototype.onMouseMove = function(e){
	if (e.screenX < $(window).width() / 3) {
		if (!$("#building-detail").hasClass("shrink"))
			$(e.data).trigger("shrink")
		$("#building-detail").addClass('shrink')
	} else if (e.screenX > $(window).width() / 2) {
		if ($("#building-detail").hasClass("shrink"))
			$(e.data).trigger("show")
		$("#building-detail").removeClass('shrink')
	}
}

Details = new DetailView()