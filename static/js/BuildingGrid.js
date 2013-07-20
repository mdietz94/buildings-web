function BuildingGrid(){
	$(Buildings).on('reset', null, this, this.reload)
	$(Buildings).on('add', null, this, this.reload)
	$(Buildings).on('clear', null, this, this.reload)
}

BuildingGrid.prototype.reload = function(e){
	$("#container").html('')
	for (var i = 0; i < Buildings.buildings.length; i++){
		bldg = Buildings.buildings[i]
		$("#container").append('<div id="' + bldg['id'] + '" class="building-element"><img src="/static/images/bldg'
			+ bldg['id'] + 'x0.jpg"></img><div class="' + 'name">' + bldg['name'] + '</div></div>')
	}
	var masonry = new Masonry('#container')
	masonry.layout()
}
