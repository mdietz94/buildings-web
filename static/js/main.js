$(function(){
	onDocumentLoad()
})
function onDocumentLoad(){
	imagesLoaded('body', initialize)
}

function initialize(){
	console.log("Images all loaded.")
	search = new SearchBar()
	grid = new BuildingGrid()
}
