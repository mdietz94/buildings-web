function DetailView(){
	// just a template empty constructor
}

DetailView.prototype.load = function(id){
	this.id = id
	// in case we are using a placeholder image
	var src = $("#" + id + ' img').attr('src')
	$('#bg').attr('src', src)
	$("#container").hide()
	$("#building-detail").show()	
}

DetailView.prototype.unload = function(){
	$("#container").show()
	$("#building-detail").hide()
}

Details = new DetailView()