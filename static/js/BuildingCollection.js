function BuildingCollection(){
	this.buildings = []
}

BuildingCollection.prototype.add = function(toAdd){
	// toAdd can either be a single element
	// or a list of elements, we check with .length
	if (toAdd.length){
		for (var i = 0; i < toAdd.length; i++){
			this.buildings.push(new Building(toAdd[i]))
		}
	} else {
		this.buildings.push(new Building(toAdd))
	}
	$(this).trigger('add')
}

BuildingCollection.prototype.reset = function(newCollection){
	this.buildings = []
	for (var i = 0; i < newCollection.length; i++){
		bldgData = newCollection[i]
		this.buildings.push(new Building(bldgData['id'], bldgData['name'], bldgData['architect']))
	}
	console.log(this.buildings)
	$(this).trigger('reset')
}

BuildingCollection.prototype.clear = function(){
	this.buildings = []
	$(this).trigger('clear')
}

BuildingCollection.prototype.get = function(id){
	ret = this.buildings.filter(function(index){ return this.id == id })
	if (ret)
		return ret[0]
	return null
}

Buildings = new BuildingCollection()
