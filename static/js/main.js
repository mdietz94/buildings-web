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
	register = new Register()
	about = new About()
	$.stellar({
		//scollProperty: 'transform', // for iOS support
		responsive: true // refresh parallax on window resize
	})
	$("#about-btn").click()
}