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
			</li>
			""")
		$(".building-list-item").click actionItemClicked

	actionItemClicked = (event) ->
		Buildings.select(event.currentTarget.id)

	selectionChanged: ->
		$(".building-list-item").removeClass 'selected'
		$("#" + Buildings.selection?.id).addClass 'selected'

class BuildingDetailView extends Backbone.View
	initialize: ->
		Buildings.bind 'change:selection', this.render

	render: ->
		$.getJSON "/find-by-id/#{Buildings.selection.get('id')}", (response) ->
			building = new Building(response)
			if building
				$("#building-detail").html("""
				<div class="building-name">#{building.get('name')}</div>
				<img class="building-image" src="/static/images/bldg0x0.jpg"></img>
				<div class="building-architect">#{if building.get('architect') then building.get('architect') else ''}</div>
				<div class="building-location">#{if building.get('address') then building.get('address') else ''}</div>
				<div class="building-location">#{if building.get('region') then building.get('region') else ''}</div>
				<div class="building-location">#{if building.get('city') then building.get('city') else ''}</div>
				<div class="building-location">#{if building.get('state') then building.get('state') else ''}</div>
				<div class="building-date">#{if building.get('date') then building.get('date') else ''}</div>
				<div class="building-description">#{if building.get('description') then building.get('description') else ''}</div>
				""")
				$.ajax {
					type: "HEAD",
					url: "/static/images/bldg#{building.get('id')}x0.jpg",
					success: ->
						$(".building-image").attr 'src', "/static/images/bldg#{building.get('id')}x0.jpg"
				}

logout = ->
	$.ajax {
		type: "GET",
		url: "/logout",
		success: ->
			$("#login-info a").click ->
				$("#login-form").show()
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

refreshUserInfo = ->
	$.getJSON "/username", (response) ->
		username = response['username']
		if username
			$("#login-info p").text "Welcome #{username}!"
			$("#login-info a").text 'Logout'
			$("#login-info a").click logout
		else
			$("#login-info p").text ''
			$("#login-info a").text 'Login'
			$("#login-info a").click ->
				$("#login-form").show()

$ ->
	Buildings.refresh()
	new BuildingsView
	new BuildingDetailView

	$("#search-bar").keyup (e) ->
		Buildings.selectionType = "text"
		Buildings.refresh()

	$("#login-form").hide()
	$("#login-form-submit").click login
	refreshUserInfo()