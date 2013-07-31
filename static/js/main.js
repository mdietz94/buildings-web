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
	login = new Login()
	$.stellar({
		//scollProperty: 'transform', // for iOS support
		responsive: true // refresh parallax on window resize
	})
}