class Building extends Backbone.Model
	initialize: ->
		if !this.get('description')
			this.set {'description': "Contribute a description to this building." }


class BuildingList extends Backbone.Collection
	model: Building
	intialize: ->
		navigator.geolocation?.getCurrentPosition (position) ->
			this.set { 'latitude': position.coords.latitude }
			this.set { 'longitude': position.coords.longitude }
		if !this.get('latitude') or !this.get('longitude')
			this.set { 'latitude': '40.7142' } # new york, ny
			this.set { 'longitude': '-74.0064' } # is the default coordinates

		$.getJSON "/find-by-location/#{this.get('latitude')}/#{this.get('longitude')}", (response) ->
			for building in response
				this.add(building)

	select: (id) ->
		building = this.get(id)
		if building
			console.log("Selecting #{id}")
			@selection = building
			this.trigger('change:selection')


Buildings = new BuildingList

class BuildingsView extends Backbone.View

	initialize: ->
		Buildings.bind 'add', this.render
		Buildings.bind 'change', this.render
		Buildings.bind 'change:selection', this.render

	render: ->
		buildingList = $("#building-list ul")
		buildingsList.html ''
		for building in Buildings
			buildingList.append(
			"""
			<li id=#{building.get('id')} class="building-list-item">
				<div class="building-list-item-name">#{building.get('name')}</div>
				<div class="building-list-item-architect">#{building.get('architect')}</div>
			</li>
			""")

	actionItemClicked = (event) ->
		Buildings.select(event.currentTarget.id)

	selectionChanged: ->
		$(".building-list-item").removeClass 'selected'
		$("#" + Buildings.selection?.id).addClass 'selected'

class BuildingDetailView extends Backbone.View
	initialize: ->
		Buildings.bind 'change:selection', this.render

	render: ->
		building = Buildings.selection
		$("#building-detail").html ''
		if building
			$("#building-detail").html(
			"""
			<div class="building-name">#{building.get('name')}</div>
			<div class="building-architect">#{building.get('architect')}</div>
			<div class="building-location">#{building.get('address')}</div>
			<div class="building-date">#{building.get('date')}</div>
			<div class="building-description">#{building.get('description')}</div>
			""")

class AppView extends Backbone.View
