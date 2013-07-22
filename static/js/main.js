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
		var top = parseInt($("#bg").css('top'))
		var height = parseInt($("#bg").css('height'))
		var bottom = top + height
		if (bottom  < $(window).scrollTop()){
			// Now the image has peeked above the screen
			$('#bg').css('top', $(window).scrollTop() + $(window).height() - 1)
		} else if (top > $(window).scrollTop() + $(window).height()){
			// The image is below the screen, so let's put it just above
			$('#bg').css('top', $(window).scrollTop() - height + 1)
		} else {
			$('#bg').css('top', $("#bg") - Math.ceil($('body').scrollTop()*0.3))
		}
	})
}