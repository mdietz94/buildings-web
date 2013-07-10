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
				<div class="building-list-item-address">#{building.get('address')}</div>
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
				<img class="building-image" src="/static/images/bldg0x0.jpg"></img>
				<div class="building-name">#{building.get('name')}</div>
				<div class="building-architect">#{building.get('architect')}</div>
				<div class="building-location">#{building.get('address')}</div>
				<div class="building-date">#{building.get('date')}</div>
				<div class="building-description">#{building.get('description')}</div>
				""")
				$.ajax {
					type: "HEAD",
					url: "/static/images/bldg#{building.get('id')}x0.jpg",
					success: ->
						$(".building-image").attr 'src', "/static/images/bldg#{building.get('id')}x0.jpg"
				}

$ ->
	Buildings.refresh()
	$("#search-bar").keyup (e) ->
		Buildings.selectionType = "text"
		Buildings.refresh()

	new BuildingsView
	new BuildingDetailView
