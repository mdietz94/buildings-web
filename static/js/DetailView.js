function DetailView(){
	// just a template empty constructor
}

DetailView.prototype.load = function(id){
	if (id){
		this.id = id
		// in case we are using a placeholder image
		var src = $("#" + id + ' img').attr('src')
		$("#building-detail").show()
		$(this).trigger('show')
		var bldg = new Building(id)
		bldg.load()
		$.getJSON("/num_images/" + id, function(r){
			bldg.numImages = r['images']
		})
		_ctx = this
		$(document).one('ajaxStop', function(){
			content = "<img id='close' src='/static/images/close.png' />"
				+ "<div class='detail-id' style='display:none;'>" + bldg.id + "</div>"
				+ "<div class='detail-name'>" + bldg.name + "</div>"
				+ "<div class='detail-architect'>" + bldg.architect + "</div>"
				+ "<div class='detail-location'>" + bldg.city + ", " + bldg.state + "</div>"
				+ "<span class='detail-date'>" + bldg.date + "</span>"
				+ "<div class='detail-map'><img src='http://maps.googleapis.com/maps/api/staticmap?markers=size:mid%7Ccolor:red%7C"
				+ bldg.latitude + "," + bldg.longitude + "&zoom=13&size=200x200&sensor=false&visual_refresh=true' alt='Google Maps'></div>"
				+ "<div class='detail-description'>" + bldg.description + "</div>"
				+ "<div id='galleria'>"
			for (var i=0;i<bldg.numImages;i++) {
				content += "<img src='/static/images/bldg" + bldg.id + "x" + i + ".jpg' alt='Image " + i + "'>"
			}
			content += "<img src='http://maps.googleapis.com/maps/api/streetview?size=600x300&location=" + bldg.latitude
				+ "," + bldg.longitude + "&sensor=false' alt='Google StreetView'></div>"
				+ "</div>"
			$("#building-detail").html(content)
			$('input[type="file"]').remove()
			$('.dropzone').remove()
			$('body').append($('<form>').addClass("dropzone").attr('action',"/images/" + bldg.id).attr('method', 'POST').dropzone({url: "/images/" + bldg.id, dictDefaultMessage: 'Drop images (or click) here'}))
			setTimeout(function(){$(".dropzone").css('left', '10%')}, 500)
			$("#close").on('click', function(){
				_ctx.unload()
			})
			$("#building-detail").removeClass('shrink')
			$(_ctx).trigger("show")
			setTimeout(function(){
				Galleria.loadTheme('/static/js/lib/galleria/themes/classic/galleria.classic.min.js')
				Galleria.run("#galleria")
			}, 1000)
		})
	} else { // we are adding a new building
		this.id = -1
		$("#building-detail").show()
		$(this).trigger("show")
		$("#building-detail").html(
			"<div class='detail-name'>Name</div>"
			+ "<div class='detail-architect'>Architect</div>"
			+ "<div class='detail-location'>Address, City, State</div>"
			+ "<span class='detail-date'>Date</span>"
			+ "<div class='detail-description'>Description</div></div>")

	}
}

DetailView.prototype.unload = function(){
	$(this).trigger('hide')
	$("#building-detail").hide()
	$(".dropzone").remove()
}

Details = new DetailView()