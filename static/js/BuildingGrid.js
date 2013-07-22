function BuildingGrid(){
	$("#container").masonry({ columnWidth: 200, itemSelector: ".building-element", gutter: 5 })
	$("#bg").css('background-image', 'url(/static/images/bldg0x0.jpg)')
	$(Buildings).on('reset', null, this, this.reload)
	$(Buildings).on('add', null, this, this.reload)
	$(Buildings).on('clear', null, this, this.reload)
}

BuildingGrid.prototype.reload = function(e){
	$newData = []
	newIds = Buildings.buildings.map(function(b){ return b.id.toString() })
	oldIds = $.map($(".building-element"), function(b){ return b.id })
	for (var i = 0; i < Buildings.buildings.length; i++){
		// we only need to do this if the id isn't already in our list
		if (oldIds.indexOf(Buildings.buildings[i].id.toString()) < 0 ){
			(function(bldg){
				var isLarge = Math.random() < 0.2
				$.get('/static/images/bldg' + bldg['id'] + 'x0.jpg').done(function(){
					var $img = $('<img>').attr('src', '/static/images/bldg' + bldg.id + 'x0.jpg')
					var $name = $('<div>').addClass('name').text(bldg.name)
					var $el = $('<div>').attr('id', bldg.id).addClass('building-element').append($img).append($name)
					$el.on('click', function(){
						Details.load(bldg.id)
					})
					if (isLarge) {
						$el.addClass('large')
					}
					$("#container").append($el).masonry('appended', $el)
				}).fail(function(){
					var $img = $('<img>').attr('src', '/static/images/bldg0x0.jpg')
					var $name = $('<div>').addClass('name').text(bldg.name)
					var $el = $('<div>').attr('id', bldg.id).addClass('building-element').append($img).append($name)
					if (isLarge) {
						$el.addClass('large')
					}
					$el.on('click', function(){
						Details.load(bldg.id)
					})
					$("#container").append($el).masonry('appended', $el)
				})
			})(Buildings.buildings[i])
		}
	}
	$oldEls = $(".building-element").filter(function(index){ return newIds.indexOf(this.id) < 0 })
	console.log('Removing ' + $oldEls.length + ' old elements.')
	for (var i = 0; i < $oldEls.length; i++){
		$("#container").masonry('remove', $oldEls[i]).masonry()
	}
}
