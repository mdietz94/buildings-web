function SearchBar() {
	this.searchHistory = []
	$("#search-bar").on('keyup', null, this, this.handleKeyPressed)
	$("#globe").on('click', null, this, this.searchByLocation)
}

SearchBar.prototype.handleKeyPressed = function(e){
	if (e.which == 13){
		e.data.search(e.target.value)
	}
}

SearchBar.prototype.search = function(terms){
	this.searchHistory.push(terms)
	$.getJSON("/search/" + terms, function(response){
		Buildings.reset(response)
	})
}

SearchBar.prototype.searchByLocation = function(){
	$.getJSON("/find-by-location/" + window.latitude + "/" + window.longitude, function(response){
		Buildings.reset(response)
	})
}