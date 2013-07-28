function InfoPane(){
	// empty constructor
}

InfoPane.prototype.load = function(id){
	// let's make sure we have all the data
	if (this.id == id){
		// we are already on this id
		return
	}

	var opts = { lines: 17, // The number of lines to draw
		length: 0, // The length of each line
		width: 2, // The line thickness
		radius: 17, // The radius of the inner circle
		corners: 1, // Corner roundness (0..1)
		rotate: 0, // The rotation offset
		direction: 1, // 1: clockwise, -1: counterclockwise
		color: '#000', // #rgb or #rrggbb
		speed: 1, // Rounds per second
		trail: 100, // Afterglow percentage
		shadow: false, // Whether to render a shadow
		hwaccel: true, // Whether to use hardware acceleration
		className: 'spinner', // The CSS class to assign to the spinner
		zIndex: 2e9, // The z-index (defaults to 2000000000)
		top: 'auto', // Top position relative to parent in px
		left: 'auto' // Left position relative to parent in px
	}
	$("#info-pane").html('')
	new Spinner(opts).spin(document.getElementById('info-pane'))
	this.id = id
	this.bldg = new Building(id)
	$(this.bldg).on('loaded', function(){
		$("#info-pane").html('<div class="info-name">' + this.name
			+ '</div><div class="info-architect">' + this.architect + '</div>'
			+ '<div class="info-distance">' + this.distance + '</div>')
		$("#info-pane").addClass("flipInX")
		setTimeout(function(){ $("#info-pane").css('opacity', '1') }, 500) // so it stays hidden until flipping in
	})
	this.bldg.load()
}

InfoPane.prototype.unload = function(){
	$("#info-pane").hide()
}

Info = new InfoPane()