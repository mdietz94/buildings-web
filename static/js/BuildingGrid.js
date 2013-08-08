function BuildingGrid(){
	$("#container").masonry({ columnWidth: 200, itemSelector: ".building-element", gutter: 5, transitionDuration: '0.6s' })
	$(Buildings).on('reset', null, this, this.reload)
	$(Buildings).on('add', null, this, this.reload)
	$(Buildings).on('clear', null, this, this.reload)
	$(Details).on('show', null, this, this.showDetail)
	$(Details).on('hide', null, this, this.hideDetail)
	$(Details).on('shrink', null, this, this.shrinkDetail)
}

BuildingGrid.prototype.showDetail = function(){
	$("#container").css('width', $(document).width()/2)
	$("#container").masonry()
}

BuildingGrid.prototype.hideDetail = function(){
	$("#container").css('width', $(document).width())
	$("#container").masonry()
}

BuildingGrid.prototype.shrinkDetail = function(){
	$("#container").css('width', '90%')
	$("#container").masonry()
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
					var $add = $('<div>').addClass('add').html('&#43;').on('click', function(){/* favorite it*/})
					var $img = $('<img>').attr('src', '/static/images/bldg' + bldg.id + 'x0.jpg')
					var $name = $('<div>').addClass('name').text(bldg.name)
					var $dist = $('<div>').addClass('distance')
					if (bldg.distance < .5) {
						$dist.text((bldg.distance*5280).toFixed() + " ft.")
					} else {
						$dist.text(bldg.distance.toFixed(1) + " mi.")
					}
					var $el = $('<div>').attr('id', bldg.id).addClass('building-element').append($add).append($img).append($name).append($dist)
					$el.on('click', function(){
						Details.load(bldg.id)
					})
					if (isLarge) {
						$el.addClass('large')
					}
					(function(x) {
						$img.on('load', function(){
							$("#container").append(x).masonry('appended', x)
						})
					})($el)
					
				}).fail(function(){
					var $add = $('<div>').addClass('add').html('&#43;').on('click', function(){/* favorite it*/})
					var $img = $('<img>').attr('src', '/static/images/bldg0x0.jpg')
					var $name = $('<div>').addClass('name').text(bldg.name)
					var $dist = $('<div>').addClass('distance')
					if (bldg.distance < .5) {
						$dist.text((bldg.distance*5280).toFixed() + " ft.")
					} else {
						$dist.text(bldg.distance.toFixed(1) + " mi.")
					}
					var $el = $('<div>').attr('id', bldg.id).addClass('building-element').append($add).append($img).append($name).append($dist)
					$el.on('click', function(){
						Details.load(bldg.id)
					})
					if (isLarge) {
						$el.addClass('large')
					}
					(function(y) {
						$img.on('load', function(){
							$("#container").append(y).masonry('appended', y)
						})
					})($el)
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
