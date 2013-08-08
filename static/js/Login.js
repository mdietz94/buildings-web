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
	$(".dropzone").hide()
	architect = $("#building-detail .detail-architect").text()
	date = $("#building-detail .detail-date").text()
	description = $("#building-detail .detail-description").text()
	if (description == "null")
		description = ''
	if (date == "null")
		date = ''
	if (architect == "Architect Unknown")
		architect = ''
	id = $("#building-detail .detail-id").text()
	name = $("#building-detail .detail-name").text()
	$.post("/edit", { 'architect': architect, 'description': description, 'date': date, 'id': id, 'name': name }).always(function(e){console.log(e)})

	makeStatic('architect')
	makeStatic('date')
	makeStatic('description')

	$("#edit").html("Edit")
	$("#add").show()
	$("#edit").one('click', _ctx, function(e){

		makeEditable('architect')
		makeEditable('date')
		makeEditable('description')

		$("#edit").html("Save Changes")
		$("#edit").one('click',e.data,_ctx.saveChanges)

		$(".dropzone").show()
	})
}

makeStatic = function(name) {
	$("#building-detail .detail-" + name).attr('contentEditable','')
	$("#building-detail .detail-" + name).removeClass('editable')
}

makeEditable = function(name) {
	$("#building-detail .detail-" + name).attr('contentEditable','true')
	$("#building-detail .detail-" + name).addClass('editable')
}

addBuilding = function(e){
	$("#add").html("Add")
	$("#edit").show()
	name = $("#building-detail .detail-name").text()
	architect = $("#building-detail .detail-architect").text()
	date = $("#building-detail .detail-date").text()
	description = $("#building-detail .detail-description").text()
	loc = $("#building-detail .detail-location").text().split(",")
	state = null
	city = null 
	address = null
	if (loc.length > 2){
		address = loc[0].trim()
		city = loc[1].trim()
		state = loc[2].trim()
	} else if (loc.length > 1){
		city = loc[0].trim()
		state = loc[1].trim()
	} else if (loc.length > 0){
		state = loc[0].trim()
	}
	geocoder = new google.maps.Geocoder();
	geocoder.geocode( { 'address': $("#building-detail .detail-location").text() }, function(results, status) {
		if (status == google.maps.GeocoderStatus.OK) {
			latitude = results[0].geometry.location.latitude
				$.post("/add", {
					'architect': architect,
					'description': description,
					'date': date,
					'name': name,
					'state': state,
					'city': city,
					'address': address,
					'latitude': results[0].geometry.location.lat(),
					'longitude': results[0].geometry.longitude.lng()
				}).always(function(e){console.log(e)})
		} else {
			alert("Geocode was not successful for the following reason: " + status);
		}
	})
	makeStatic('name')
	makeStatic('architect')
	makeStatic('date')
	makeStatic('description')
	makeStatic('location')
}

Login.prototype.refresh = function(){
	_ctx = this
	$.getJSON("/username", function(response){
		username = response['username']
		if (username){
			// we are logged in -- let's display account settings (user info, logout, etc.)
			$("#menu-data").html('<li id="add">Add</li>'
				+ '<li id="edit">Edit</li>'
				+ '<li class="bar"></li>'
				+ '<li id="logout">Log Out</li>')

			$("#logout").one('click', function(){
				_ctx.logout()
			})
			$("#edit").one('click', _ctx, function(e){
				$("#add").hide()
				$("#edit").html("Save Changes")
				$("#edit").one('click',e.data, e.data.saveChanges)

				makeEditable('architect')
				makeEditable('date')
				makeEditable('description')
				$(".dropzone").show()
			})
			$("#add").one('click', _ctx, function(e){
				$("#add").html("Save Changes")
				$("#edit").hide()
				Details.load()
				makeEditable('name')
				makeEditable('architect')
				makeEditable('date')
				makeEditable('location')
				//makeEditable() use a map for location?
				makeEditable('description')

				$("#add").one('click', e.data, addBuilding)
				$(Details).one('show', e.data, addBuilding)
			})

			// Is there anything to edit?
			if (!$("#building-detail").is(":visible")){
				$("#edit").hide()
			}
			$(Details).on('hide', function(){
				$("#edit").hide()
			})
			$(Details).on('show', function(){
				if ($("#add").html() != "Save Changes")
					$("#edit").show()
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

