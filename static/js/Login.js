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
	_ctx = this
	$.post('/login', { username: $("#login-form-username").val(), password: $("#login-form-password").val() }).fail(function(){
		alert("THERE WAS A PROBLEM!")
	}).always(function(){
		//$("#login-form").hide()
		_ctx.refresh()
	})
}

Login.prototype.saveChanges = function(e){
	// this may not belong in login...
	// anyway, do the saving then...
	_ctx = e.data
	newVal = $("#building-detail .detail-architect").val()
	newDiv = $("<div class='detail-architect'></div>")
	newDiv.text(newVal)
	$("#building-detail .detail-architect").replaceWith(newDiv)
	$("#edit").html("Edit")
	$("#edit").one('click', _ctx, function(e){
		editText = $("#building-detail .detail-architect").text()
		editableArea = $("<textarea class='detail-architect' />")
		editableArea.val(editText)
		$("#building-detail .detail-architect").replaceWith(editableArea)
		editableArea.focus()
		$("#edit").html("Save Changes")
		$("#edit").one('click',e.data,_ctx.saveChanges)
	})
}

Login.prototype.refresh = function(){
	_ctx = this
	$.getJSON("/username", function(response){
		username = response['username']
		if (username){
			// we are logged in -- let's display account settings (user info, logout, etc.)
			$("#menu-data").html('<li>Settings</li>'
				+ '<li id="edit">Edit</li>'
				+ '<li class="bar"></li>'
				+ '<li id="logout">Log Out</li>')
			$("#logout").one('click', function(){
				_ctx.logout()
			})
			$("#edit").one('click', _ctx, function(e){
				$("#edit").html("Save Changes")
				$("#edit").one('click',e.data, e.data.saveChanges)
				editText = $("#building-detail .detail-architect").text()
				editableArea = $("<textarea class='detail-architect' />")
				editableArea.val(editText)
				$("#building-detail .detail-architect").replaceWith(editableArea)
				editableArea.focus()
			})
		} else {
			// we are not logged in
			$("#menu-data").html('<input type="text" id="login-form-username" placeholder="Username"></input>'
				+ '<input type="password" id="login-form-password" placeholder="Password"></input>'
				+ '<input id="login-submit" value="Log In" type="submit"></input>'
				+ '<a id="register" href="#register">Register an account</a>')
			$("#login-submit").one('click', function(){
				_ctx.login()
			})
		}
	})
}

