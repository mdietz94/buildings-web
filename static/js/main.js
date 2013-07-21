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
	$(window).scroll(function(){
		$('body').css('background-position', '50% -' + Math.ceil($('body').scrollTop()*0.3) + 'px')	
	})
}