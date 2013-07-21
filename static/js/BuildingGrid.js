function BuildingGrid(){
	$("#container").masonry({columnWidth: 100})
	$(Buildings).on('reset', null, this, this.reload)
	$(Buildings).on('add', null, this, this.reload)
	$(Buildings).on('clear', null, this, this.reload)
}

BuildingGrid.prototype.reload = function(e){
	$newData = []
	ids = []
	for (var i = 0; i < Buildings.buildings.length; i++){
		(function(bldg){
			ids.push(bldg['id'])
			$.ajax({
				type: "HEAD",
				url: '/static/images/bldg' + bldg['id'] + 'x0.jpg',
				success: function(){
					var $img = $('<img>').attr('src', '/static/images/bldg' + bldg['id'] + 'x0.jpg')
					var $name = $('<div>').addClass('name').text(bldg['name'])
					var $el = $('<div>').attr('id', bldg['id']).addClass('building-element').append($img).append($name)
					$newData.push($el)
				},
				error: function(){
					var $img = $('<img>').attr('src', '/static/images/bldg0x0.jpg')
					var $name = $('<div>').addClass('name').text(bldg['name'])
					var $el = $('<div>').attr('id', bldg['id']).addClass('building-element').append($img).append($name)
					$newData.push($el)				}
			})
		})(Buildings.buildings[i])
	}
	$(document).ajaxStop(function(){
		$oldEls = $(".building-element")
		if ($oldEls.length > 0) {
			oldIds = $.map($oldEls, function(b){ return b.id })
			for (var i = 0; i < $oldEls.length; i++){
				if (ids.indexOf($oldEls[i].id) < 0){
					$("#container").masonry('remove', $oldEls[i]).masonry()
				}
			}
		}
		console.log('Adding (or checking) ' + $newData.length + ' new elements.')
		for (var i = 0; i < $newData.length; i++){
			if ($oldEls.length <= 0 || oldIds.indexOf($newData[i].id) < 0) {
				$("#container").append($newData[i]).masonry('appended', $newData[i], true)
			}
		}
		console.log("Completed search.")
	})
}
