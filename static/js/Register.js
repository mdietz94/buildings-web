Register = function(){
	console.log('b')
	$(window).on('hashchange', function(){
		if (location.hash == '#register') {
			$("#register-form").show()
			$("#register-form").addClass('fadeInUp')
		}
	})

	$("#register-form input[type='submit']").on('click', function(){
		$.post("/register", {
			'username': $("#register-form input[type='text']").val(),
			'password': $("#register-form input[type='password']").val()
		})
		$("#register-form").removeClass('fadeInUp')
		$("#register-form").addClass('fadeOutDown')
		setTimeout(function(){ $("#register-form").hide() }, 1000)
	})
}
