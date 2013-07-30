Login = function(){
	// Empty constructor
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
	// here we check whether we are logged in
	// and update any messages accordingly
	// this should get called whenever we do a
	// login or logout to make sure it actually
	// did what it was supposed to.
}