function Building(_id){
	this.id = _id
}

function Building(_id, name, architect){
	this.id = _id
	this.name = name
	this.architect = architect
}
Building.prototype.load = function(){
	$.getJSON("/find-by-id/" + this._id, function(response){
		this.name = response['name']
		this.architect = response['architect']
		this.country = response['country']
		this.state = response['state']
		this.city = response['city']
		this.region = response['region']
		this.address = response['address']
		this.latitude = response['latitude']
		this.longitude = response['longitude']
		this.date = response['date']
		this.description = response['description']
		this.keywords = response['keywords']
	})
}
