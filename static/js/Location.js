_ctx = undefined
function Location(){
	_ctx = this
	if (!navigator.geolocation) {
		// no way to get a location fix
		$(this).trigger('lost')
		return
	}
	this.refresh()	
}

Location.prototype.refresh = function(){
	// If we have had a location fix
	// in the last ten seconds, there is
	// no reason to refresh
	navigator.geolocation.getCurrentPosition(
		this.onFix,
		this.onLost,
		{ enableHighAccuracy: true, maximumAge: 10000 })
}

Location.prototype.onFix = function(position){
	window.latitude = position.coords.latitude
	window.longitude = position.coords.longitude
}

Location.prototype.onLost = function(){
	$(this).trigger('lost')
}

LocationServices = new Location()