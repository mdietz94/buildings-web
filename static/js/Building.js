function Building(opts){
	this.id = opts.id
	this.name = opts.name
	this.architect = opts.architect
	this.address = opts.address
	this.latitude = opts.latitude
	this.longitude = opts.longitude

	var lat1 = this.latitude * (Math.PI / 180)
	var lon1 = this.longitude * (Math.PI / 180)
	var lat2 = window.latitude * (Math.PI / 180)
	var lon2 = window.longitude * (Math.PI / 180)
	this.distance = 'Some'
	if (lat2 != null) { // we can assume that either both or neither will be null
		var x = (lon2 - lon1) * Math.cos((lat2 + lat1)/2)
		var y = lat2 - lat1
		this.distance = Math.sqrt(x*x + y*y) * 3959 // for miles, in KM it would be 6371
	}
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
		bldg.address = response['address']
		bldg.latitude = response['latitude']
		bldg.longitude = response['longitude']
		bldg.date = response['date']
		bldg.description = response['description']
		bldg.keywords = response['keywords']
		var lat1 = bldg.latitude * (Math.PI / 180)
		var lon1 = bldg.longitude * (Math.PI / 180)
		var lat2 = window.latitude * (Math.PI / 180)
		var lon2 = window.longitude * (Math.PI / 180)
		if (lat2 != null) { // we can assume that either both or neither will be null
			var x = (lon2 - lon1) * Math.cos((lat2 + lat1)/2)
			var y = lat2 - lat1
			bldg.distance = (Math.sqrt(x*x + y*y) * 3959) // for miles, in KM it would be 6371
		}
		$(bldg).trigger('loaded')
	})
}
