function BuildingGrid(){
	$("#container").masonry({ columnWidth: 200, itemSelector: ".building-element", gutter: 5, transitionDuration: '0.6s' })
	$("#bg").css('background-image', 'url(/static/images/bldg0x0.jpg)')
	$(Buildings).on('reset', null, this, this.reload)
	$(Buildings).on('add', null, this, this.reload)
	$(Buildings).on('clear', null, this, this.reload)
	$(Details).on('show', null, this, this.showDetail)
	$(Details).on('hide', null, this, this.hideDetail)
	$(Details).on('shrink', null, this, this.shrinkDetail)
}

BuildingGrid.prototype.showDetail = function(){
	$("#container").css('width', document.width/2)
	$("#container").masonry()
}

BuildingGrid.prototype.hideDetail = function(){
	$("#container").css('width', document.width)
	$("#container").masonry()
}

BuildingGrid.prototype.shrinkDetail = function(){
	$("#container").css('width', '90%')
	$("#container").masonry()
}

BuildingGrid.prototype.reload = function(e){
	$newData = []
	newIds = Buildings.buildings.map(function(b){ return b.id.toString() })
	newIds.push('*')
	newIds.push('**')
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
					$("#" + bldg.id).mouseover(function(){
						Info.load(parseInt($(this).attr('id')))
					})
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
					$("#" + bldg.id).mouseover(function(){
						Info.load(parseInt($(this).attr('id')))
					})
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
