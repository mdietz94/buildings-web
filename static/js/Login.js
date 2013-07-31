Login = function(){
	$(".tooltip a").on('click', function(e){
		if ($(".tooltip span:hidden").length > 0)
			$(".tooltip span:hidden").show()
		else
			$(".tooltip span").hide()
	})
	$("#bg").on('click', function(e){
		$(".tooltip span").hide()
		console.log(e.target)
	})
	$("#building-detail").on('click', function(e){
		$(".tooltip span").hide()
		console.log(e.target)
	})
	$("#container").on('click', function(e){
		$(".tooltip span").hide()
		console.log(e.target)
	})

	this.refresh()
}

Login.prototype.logout = function(){
	_ctx = this
	$.get('/logout').always(function(){
		_ctx.refresh()
	})
}

Login.prototype.login = function(){
	$.post('/login', { username: $("#login-form-username").val(), password: $("#login-form-password").val() }).fail(function(){
		alert("THERE WAS A PROBLEM!")
	}).always(function(){
		//$("#login-form").hide()
		_ctx.refresh()
	})
}

Login.prototype.refresh = function(){
	_ctx = this
	$.getJSON("/username", function(response){
		username = response['username']
		if (username){
			// we are logged in -- let's display account settings (user info, logout, etc.)
			$("#menu-data").html('<li>Option 1</li>'
				+ '<li>Option 2</li>'
				+ '<li class="bar"></li>'
				+ '<li id="logout">Log Out</li>')
			$("#logout").one('click', function(){
				_ctx.logout()
			})
		} else {
			// we are not logged in
			$("#menu-data").html('<input type="text" id="login-form-username" placeholder="Username"></input>'
				+ '<input type="password" id="login-form-password" placeholder="Password"></input>'
				+ '<input id="login-submit" type="submit"></input>')
			$("#login-submit").one('click', function(){
				_ctx.login()
			})
		}
	})
}
