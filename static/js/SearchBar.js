function SearchBar() {
	this.searchHistory = []
	$("#search-bar").on('keyup', null, this, this.handleKeyPressed)
}

SearchBar.prototype.handleKeyPressed = function(e){
	if (e.which == 13){
		e.data.search(e.target.value)
	}
}

SearchBar.prototype.search = function(terms){
	this.searchHistory.push(terms)
	$.getJSON("/search/" + terms, function(response){
		console.log(response)
		Buildings.reset(response)
	})
}
