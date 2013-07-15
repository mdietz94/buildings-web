class Building extends Backbone.Model
	initialize: ->
		if !this.get('description')
			this.set {'description': "Contribute a description to this building." }
		if !this.get('architect')
			this.set {'architect': "Unknown Architect"}
		if !this.get('enabled')
			this.set { 'enabled': true }

# # #
# BuildingGrid will store all the buildings returned by the first search query
# and afterwards, will just set buildings.enabled to represent whether each
# building is still relevant to the query.  That way there will be a difference
# between the background buildings that were never relevant and buildings that
# we can fade out to show they were relevant but were since queried against.
# # #
class BuildingGrid extends Backbone.Collection
	model: Building
	initialize: ->
		@query = ''
		# The first time we will reset our collection to the returned response,
		# but afterwards we will keep the collection, but change the enabled variable
		@first = true
	clear = ->
		@query = ''
	append = (additional) ->
		@query += additional
	select: (id) ->
		building = this.get(id)
		if building
			console.log("Selecting #{id}")
			@selection = building
			this.trigger('change:selection')
	refresh: ->
		context = this
		# The search bar should clear when we hit enter,
		# so we are treating queries like a stack
		@query += $("#search-bar").val() + ' '
		$.getJSON "/search/#{@query}", (response) ->
			if context.first
				context.reset response
			else
				ids = response.map (b) -> b['id']
				context.reset (context.models.map (m) -> m.set( { 'enabled': false } ) if not m.get('id') in ids)
			context.trigger('change:query')
		@first = false

Buildings = new BuildingGrid

class BuildingsView extends Backbone.View

	initialize: ->
		#Buildings.bind 'reset', this.render
		Buildings.bind 'change:selection', this.selectionChanged
		Buildings.bind 'change:query', this.queryChanged
		context = this
		backGrid = $("#background-grid")
		backGrid.html ''
		for i in [0..200]
			$.ajax {
				type: 'HEAD'
				url: "/static/images/bldg#{i}x0.jpg"
				id: i
				success: ->
					console.log @url
					backGrid.append "<img width='64px' src='#{@url}' id='#{@id}'></img>"
					console.log "added a pic"
					$("#" + @id).css 'left', '50%'
					$("#" + @id).css 'top', '50%'
					loopRandom(@id)
			}

	randomizePosition = (id) ->
		$("#" + id).css 'left', Math.floor(Math.random()*100) + "%"
		$("#" + id).css 'top', Math.floor(Math.random()*100) + "%"

	loopRandom = (id) ->
		randomizePosition(id)
		setTimeout ( -> loopRandom(id) ), 2000

	clearTimers: ->
		for i in [0..setTimeout(';')]
			clearTimeout(i)
		$("#background-grid img").css 'left', ''
		$("#background-grid img").css 'top', ''
		$("#background-grid img").css 'opacity', 0
		setTimeout ( -> $("#background-grid img").addClass 'disabled' ), 2000
		setTimeout ( -> $("#background-grid img").css 'opacity', .1 ), 3000
		$("#background-grid").css 'z-index', -1

	startTimers = ->
		for elem in $("#background-grid img")
			loopRandom(elem.id)
		$("#background-grid").css 'z-index', 0
		$("#background-grid img").css 'opacity', 1
		$("#background-grid img").removeClass 'disabled'

	render: ->
		buildingList = $("#building-list")
		if Building.models?.length > 0
			buildingList.html ''
		else
			buildingList.html '<span>bldg</span>'
		for building in Buildings.models
			img_url = ''
			$.ajax {
				type: 'HEAD',
				url: "/static/images/bldg#{building.get("id")}x0.jpg"
				error: ->
					buildingList.append("""<img id=#{building.get('id')} src="/static/images/0x0.jpg" class="building-list-item #{'disabled' if not building.get('enabled')}"></img>""")
				success: ->
					buildingList.append("""<img id=#{building.get('id')} src="/static/images/#{building.get("id")}x0.jpg" class="building-list-item #{'disabled' if not building.get('enabled')}"></img>""")
			}
		$(".building-list-item").bind 'click', (e) ->
			actionItemClicked(e)

	actionItemClicked = (event) ->
		Buildings.select(event.currentTarget.id)

	selectionChanged: ->
		$(".building-list-item").removeClass 'selected'
		$("#" + Buildings.selection?.id).addClass 'selected'
		$(".selected .building-list-item-button").unbind 'click'
		$(".selected .building-list-item-button").bind 'click', BuildingDetailView.prototype.enableEditing

	queryChanged: ->
		$(".building-list-item").unbind 'click'
		this.render()
		enabledBldgs = _.filter(Building.models, (m) -> m.get('enabled'))
		size = 90 / enabledBldgs.length
		x = y = 0
		for building in enabledBldgs
			$("#" + building.get('id')).css 'left', x
			$("#" + building.get('id')).css 'left', y
			$("#" + building.get('id')).css 'height', size + '%'
			$("#" + building.get('id')).css 'width', size + '%'
			x += size
			if x + size > 100
				x = 0
				y += size
		$(".building-list-item:not(.disabled)").bind 'click', (e) ->
			actionItemClicked(e)
		


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
				<div class="building-name">#{building.get('name')}
				<img src='/static/images/delete.png' id='delete-button' height='35px' style='right: 10px; position: absolute;'></img>
				</div>
				<img class="building-image" src=""></img>
				<div class="building-architect">#{if building.get('architect') then building.get('architect') else ''}</div>
				<div class="building-address">#{if building.get('address') then building.get('address') else ''}</div>
				<div class="building-region">#{if building.get('region') then building.get('region') else ''}</div>
				<div class="building-city">#{if building.get('city') then building.get('city') else ''}</div>
				<div class="building-state">#{if building.get('state') then building.get('state') else ''}</div>
				<div class="building-date">#{if building.get('date') then building.get('date') else ''}</div>
				<div class="building-description">#{if building.get('description') then building.get('description') else ''}</div>
				<input id='new-image' type='file'></input>
				<div class='loading'></div>
				<input style='display: none;' id="cancel-button" type='submit' value='Cancel'></input>
				""")
				$("#delete-button").bind 'click', BuildingDetailView.prototype.deleteBuilding
				$("#new-image").change (e) ->
					uid = $(".building-id").text()
					xhr = new XMLHttpRequest()
					fd = new FormData()
					xhr.open 'POST', "/images/#{uid}", true
					xhr.onreadystatechange = ->
						if xhr.readyState == 4
							$('.loading').spin(false)
							if xhr.status == 200
								alert("Uploaded successfully.")
								Buildings.trigger('change:selection')
							else
								alert("You must be logged in and have permission to upload files.")
					fd.append 'data', e.target.files[0]
					xhr.send fd
					e.target.value = ''
					$('.loading').spin( { 'lines': 15, 'length': 0, 'width': 4, 'radius': 20, 'corners': 0,
					'rotate': 0, 'trail': 64, 'speed': 1.0, 'direction': 1 })
				$.ajax {
					type: "HEAD",
					url: "/static/images/bldg#{building.get('id')}x0.jpg",
					success: ->
						$(".building-image").attr 'src', "/static/images/bldg#{building.get('id')}x0.jpg"
					error: ->
						$(".building-image").attr 'src', '/static/images/bldg0x0.jpg'
				}

	enableEditing: ->
		replaceEl(".building-description")
		replaceEl(".building-name")
		replaceEl(".building-architect", 'Architect')
		replaceEl(".building-date", 'Date')
		$("#cancel-button").show()
		$("#cancel-button").click ->
			Buildings.trigger('change:selection')
			$(".selected .building-list-item-button").toggleClass 'flip'
			f = ->
				$(".selected .building-list-item-button").html 'Edit'
			setTimeout f, 500
		$(".selected .building-list-item-button").toggleClass 'flip'
		f = ->
			$(".selected .building-list-item-button").html 'Save'
		setTimeout f, 500
		$(".selected .building-list-item-button").unbind 'click'
		$(".selected .building-list-item-button").click ->
			building = { id: $(".building-id").text(), name: $.trim($(".building-name").val()), architect: $.trim($(".building-architect").val()), 
			description: $.trim($(".building-description").val()), date: $.trim($(".building-date").val()) }
			$.ajax {
				type: "POST",
				url: "/edit",
				data: building,
				success: ->
					Buildings.trigger 'change:selection'
					$(".selected .building-list-item-button").toggleClass 'flip'
					f = ->
						$(".selected .building-list-item-button").html 'Edit'
					setTimeout f, 500
				error: ->
					alert("Error: You must be logged in and have access.")
					Buildings.trigger 'change:selection'
					$(".selected .building-list-item-button").toggleClass 'flip'
					f = ->
						$(".selected .building-list-item-button").html 'Edit'
					setTimeout f, 500
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
		type: 'POST'
		url: "/add"
		data: building
		success: ->
			alert("Building added!")
		error: ->
			alert("An error has occured!")
	}

$ ->
	Buildings.refresh()
	BuildingView = new BuildingsView
	new BuildingDetailView

	$("#search-bar").keyup (e) ->
		if e.which == 13
			console.log 'pressed'
			Buildings.refresh()
			BuildingView.clearTimers()


	$("#login-form").hide()
	$("#login-form-submit").click login
	$("#login-form-register").click register
	refreshUserInfo()
	$("#building-list span").css 'opacity', 1
	f = -> $("#building-list span").css 'opacity', .4
	setTimeout f, 6000
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
