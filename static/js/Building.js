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
		if (bldg.architect == null){
			bldg.architect = "Architect Unknown"
		}
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
		var lat1 = bldg.latitude * (Math.PI / 180)
		var lon1 = bldg.longitude * (Math.PI / 180)
		var lat2 = LocationServices.latitude * (Math.PI / 180)
		var lon2 = LocationServices.longitude * (Math.PI / 180)
		if (lat2 != null) { // we can assume that either both or neither will be null
			var x = (lon2 - lon1) * Math.cos((lat2 + lat1)/2)
			var y = lat2 - lat1
			bldg.distance = (Math.sqrt(x*x + y*y) * 3959).toFixed(1) // for miles, in KM it would be 6371
		}
		$(bldg).trigger('loaded')
	})
}
