About = function(){
	$("#about img").on('click', this.hide)
	$("#about-btn").on('click', this.show)
}

About.prototype.show = function(){
	$("#about").css('top','50px')
}

About.prototype.hide = function(){
	$("#about").css('top','')
}