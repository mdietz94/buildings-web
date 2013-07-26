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
	$(document).one('ajaxStop', function(){
		$("#building-detail").html("<div class='detail-name'>" + bldg.name + "</div>"
			+ "<div class='detail-architect'>" + bldg.architect + "</div>"
			+ "<div class='detail-location'>" + bldg.city + ", " + bldg.state + "</div>"
			+ "<div class='detail-description'>" + bldg.description + "</div>"
			+ "<div id='galleria'><img src='/static/images/bldg" + bldg.id + "x0.jpg' alt='/static/images/bldg0x0.jpg'></div>"
			+ "</div>")
		Galleria.loadTheme('/static/js/lib/galleria/themes/classic/galleria.classic.min.js')
		Galleria.run("#galleria")
	})
}

DetailView.prototype.unload = function(){
	$("#building-detail").hide()
	$(this).trigger('hide')
}

Details = new DetailView()