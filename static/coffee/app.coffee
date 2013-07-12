class Building extends Backbone.Model
	initialize: ->
		if !this.get('description')
			this.set {'description': "Contribute a description to this building." }

class BuildingList extends Backbone.Collection
	model: Building

	initialize: ->
		this.selectionType = "position"

	select: (id) ->
		building = this.get(id)
		if building
			console.log("Selecting #{id}")
			@selection = building
			this.trigger('change:selection')
	refresh: ->
		switch this.selectionType
			when "position"
				navigator.geolocation?.getCurrentPosition (position) ->
					lat =  position.coords.latitude
					long = position.coords.longitude
				if !lat or !long
					lat = '40.7142'
				long = '-74.0064' # nyc is default coordinates
				context = this
				console.log 'refreshing by position'
				$.getJSON "/find-by-location/#{lat}/#{long}", (response) ->
					context.reset(response)
			when "text"
				context = this
				console.log "refreshing by text #{$("#search-bar").val()}"
				$.getJSON "/find-by-name/#{$("#search-bar").val()}", (response) ->
					context.reset(response)

Buildings = new BuildingList

class BuildingsView extends Backbone.View

	initialize: ->
		Buildings.bind 'reset', this.render
		Buildings.bind 'change', this.render
		Buildings.bind 'change:selection', this.selectionChanged
		this.render()

	render: ->
		buildingList = $("#building-list")
		buildingList.html ''
		for building in Buildings.models
			buildingList.append("""
			<li id=#{building.get('id')} class="building-list-item">
				<div class="building-list-item-name">#{building.get('name')}</div>
				<div class="building-list-item-architect">#{if building.get('architect') then building.get('architect') else ''}</div>
				<img src="/static/images/pencil.png" height="70px" ></img>
			</li>
			""")
		$(".building-list-item").click (e) ->
			if e.target != $(".selected img")[0] 
				actionItemClicked(e)

	actionItemClicked = (event) ->
		Buildings.select(event.currentTarget.id)

	selectionChanged: ->
		$(".building-list-item").removeClass 'selected'
		$("#" + Buildings.selection?.id).addClass 'selected'
		$(".building-list-item img").unbind 'click'
		$(".selected img").bind 'click', BuildingDetailView.prototype.enableEditing

class BuildingDetailView extends Backbone.View
	initialize: ->
		Buildings.bind 'change:selection', this.render
		this.first = true

	render: ->
		if not this.first
			$("#building-detail").addClass('flip')
			setTimeout applyChange, 500
		else
			applyChange()
			this.first = false

	applyChange = ->
		$("#building-detail").removeClass('flip')
		$.getJSON "/find-by-id/#{Buildings.selection.get('id')}", (response) ->
			this.building = building = new Building(response)
			if building
				$("#building-detail").html("""
				<div style="display: none;" class="building-id">#{building.get('id')}</div>
				<div class="building-name">#{building.get('name')}</div>
				<img class="building-image" src="/static/images/bldg0x0.jpg"></img>
				<div class="building-architect">#{if building.get('architect') then building.get('architect') else ''}</div>
				<div class="building-address">#{if building.get('address') then building.get('address') else ''}</div>
				<div class="building-region">#{if building.get('region') then building.get('region') else ''}</div>
				<div class="building-city">#{if building.get('city') then building.get('city') else ''}</div>
				<div class="building-state">#{if building.get('state') then building.get('state') else ''}</div>
				<div class="building-date">#{if building.get('date') then building.get('date') else ''}</div>
				<div class="building-description">#{if building.get('description') then building.get('description') else ''}</div>
				<input id="delete-button" type='submit' value='Delete'></input>
				<input style='display: none;' id="cancel-button" type='submit' value='Cancel'></input>
				""")
				$("#delete-button").bind 'click', BuildingDetailView.prototype.deleteBuilding
				$.ajax {
					type: "HEAD",
					url: "/static/images/bldg#{building.get('id')}x0.jpg",
					success: ->
						$(".building-image").attr 'src', "/static/images/bldg#{building.get('id')}x0.jpg"
				}

	enableEditing: ->
		replaceEl(".building-description")
		replaceEl(".building-name")
		replaceEl(".building-architect", 'Architect')
		replaceEl(".building-date", 'Date')
		$("#cancel-button").show()
		$("#cancel-button").click ->
			Buildings.trigger('change:selection')
		$("#edit-button").unbind 'click'
		$("#edit-button").val 'Save'
		$("#edit-button").click ->
			building = { id: $(".building-id").text(), name: $(".building-name").val(), architect: $(".building-architect").val(), 
			description: $(".building-description").val(), date: $(".building-date").val() }
			console.log building
			$.ajax {
				type: "POST",
				url: "/edit",
				data: building,
				success: ->
					Buildings.trigger 'change:selection'
				}

	deleteBuilding: ->
		uid = Buildings.selection.get('id')
		$.ajax {
			type: 'DELETE',
			url: "/find-by-id/#{uid}",
			success: ->
				alert("Building deleted!")
			error: ->
				alert("An error has occured!")
		}

replaceEl = (selector, placeholder='') ->
	el = $(selector)
	data = el.text()
	savedClass = el.attr 'class'
	el.replaceWith "<textarea class='#{savedClass}' placeholder='#{placeholder}'></textarea>"
	$(".#{savedClass}").html data


logout = ->
	$.ajax {
		type: "GET",
		url: "/logout",
		success: ->
			refreshUserInfo()
	}

login = ->
	$.ajax {
		type: "POST",
		url: "/login",
		data: { username: $("#login-form-username").val(), password: $("#login-form-password").val() },
		success: ->
			$("#login-form").hide()
			refreshUserInfo()
		error: (e) ->
			$("#login-form").hide()
			alert("There was an error logging in!")
			console.log e
	}

register = ->
	$.ajax {
		type: "POST",
		url: "/register",
		data: { username: $("#login-form-username").val(), password: $("#login-form-password").val() },
		dataType: 'json'
		success: (response) ->
			$("#login-form").hide()
			if response.message != 'OK'
				alert(response.message)
			refreshUserInfo()
		error: (e) ->
			$("#login-form").hide()
			alert("There was an error registering!")
			console.log e
	}	

refreshUserInfo = ->
	$.getJSON "/username", (response) ->
		username = response['username']
		if username
			console.log 'user logged in'
			$("#login-info p").text "Welcome #{username}!"
			$("#login-info a").text 'Logout'
			$("#login-info a").unbind 'click'
			$("#login-info a").click logout
		else
			console.log 'user logged out'
			$("#login-info p").text ''
			$("#login-info a").text 'Login'
			$("#login-info a").unbind 'click'
			$("#login-info a").click ->
				$("#login-form").show()


addBuilding = (building) ->
	$.ajax {
		type: 'POST',
		url: "/add",
		data: building,
		success: ->
			alert("Building added!")
		error: ->
			alert("An error has occured!")
	}

$ ->
	Buildings.refresh()
	new BuildingsView
	new BuildingDetailView

	$("#search-bar").keyup (e) ->
		Buildings.selectionType = "text"
		Buildings.refresh()

	$("#login-form").hide()
	$("#login-form-submit").click login
	$("#login-form-register").click register
	refreshUserInfo()

	$("#add-building").click ->
		$("#building-detail").html("""
		<textarea class="building-name" placeholder='name'></textarea>
		<textarea class="building-architect" placeholder='architect'></textarea>
		<textarea class="building-latitude" placeholder='latitude'></textarea>
		<textarea class="building-longitude" placeholder='longitude'></textarea>
		<textarea class="building-address" placeholder='address'></textarea>
		<textarea class="building-region" placeholder='region'></textarea>
		<textarea class="building-city" placeholder='city'></textarea>
		<textarea class="building-state" placeholder='state'></textarea>
		<textarea class="building-date" placeholder='date'></textarea>
		<textarea class="building-description" placeholder='description'></textarea>
		<textarea class="building-keywords" placeholder='keywords (separate with semi-colons or whitespace )'></textarea>
		<input id="submit-button" type='submit' value='Submit'></input>
		<input id="cancel-button" type='submit' value='Cancel'></input>
		""")
		$("#cancel-button").click ->
			$("#building-detail").html ''
		$("#submit-button").click ->
			addBuilding { name: $(".building-name").val(), architect: $(".building-architect").val(), 
			latitude: $(".building-latitude").val(), longitude: $(".building-longitude").val(), 
			address: $(".building-address").val(), region: $(".building-region").val(), 
			city: $(".building-city").val(), state: $(".building-state").val(), 
			date: $(".building-date").val(), description: $(".building-description").val(),
			keywords: $(".building-keywords").val() }
