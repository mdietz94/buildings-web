function Building(_id){
	this.id = _id
}

function Building(_id, name, architect){
	this.id = _id
	this.name = name
	this.architect = architect
}
Building.prototype.load = function(){
	bldg = this
	$.getJSON("/find-by-id/" + this.id, function(response){
		console.log(response)
		bldg.name = response['name']
		bldg.architect = response['architect']
		bldg.country = response['country']
		bldg.state = response['state']
		bldg.city = response['city']
		bldg.region = response['region']
		bldg.address = response['address']
		bldg.latitude = response['latitude']
		bldg.longitude = response['longitude']
		bldg.date = response['date']
		bldg.description = response['description']
		bldg.keywords = response['keywords']
		$(bldg).trigger('loaded')
	})
}
