class Building extends Backbone.Model
	initialize: ->
		if !this.get('description')
			this.set {'description': "Contribute a description to this building." }
		if !this.get('architect')
			this.set {'architect': "Unknown Architect"}

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
		context = this
		console.log "refreshing by text #{$("#search-bar").val()}"
		$.getJSON "/find-by-name/#{$("#search-bar").val()}", (response) ->
			context.reset(response)

Buildings = new BuildingList

init = ->
	window.app = {}
	window.app.bitmaps = []
	window.app.canvas = document.getElementById("canvas")
	window.app.stage = new createjs.Stage(window.app.canvas)
	window.app.stage.enableMouseOver(50)
	window.app.stage.autoClear = false
	window.app.floating = true
	Buildings.on 'reset', refresh
	$.getJSON "/static/images", (r) ->
		files = r['files'].filter((f) -> f.match("thumb_bldg") )
		console.log files
		i = 0
		for i in [0..20]
			filename = files[_.random(files.length)]
			img = new Image()
			img.src = "/static/images/" + filename
			img.onload = handleImageLoad
		createjs.Ticker.setFPS(30)
		createjs.Ticker.addEventListener 'tick', tick

refresh = ->
	if window.app.first
		window.app.first = false
		window.app.stage.removeAllChildren()
		window.app.bitmaps = []
		$.getJSON "/static/images", (r) ->
				files = r['files']
				for b in Buildings.models
					img = new Image()
					if "bldg" + b.get('id') + "x0.jpg" in files
						img.src = "/static/images/bldg" + b.get('id') + "x0.jpg"
					else
						img.src = "/static/images/bldg0x0.jpg"
					((i) ->
						img.onload = (e) -> handleImageLoad(e, i)
					)(b['id'])
	else
		ids = Buildings.models.map( (m) -> "#{m.get('id')}" )
		toRemove = []
		for child in window.app.stage.children
			n = child.name.split("bldg")[1].split("x")[0]
			if ids.indexOf(n) < 0
				createjs.Tween.get(child).to({skewX: 90}, 1000, createjs.Ease.linear)
				toRemove.push child
		((toRemove) ->
			setTimeout(( ->
				for r in toRemove
					window.app.stage.removeChild(r)
			), 1000)
		)(toRemove)



handleImageLoad = (e, id) ->
	console.log e
	bitmap = new createjs.Bitmap(e.target)
	console.log bitmap.image.height
	bitmap.scaleX = bitmap.scaleY = bitmap.scale = 128.0 / bitmap.image.width
	if id
		bitmap.name = "/static/images/bldg" + id + "x0.jpg"
	else
		bitmap.name = bitmap.image.src
	window.app.bitmaps.push bitmap.name
	bitmap.regX = bitmap.image.width*bitmap.scaleX  /2
	bitmap.regY = bitmap.image.height*bitmap.scaleY  /2
	bitmap.rotation = _.random(-10,10)
	bitmap.velocities = {x: 0, y: 0 }
	bitmap.addEventListener 'mouseover', (e) ->
		bitmap = e.target
		bitmap.scaleX = bitmap.scaleY = bitmap.scale*1.2
	bitmap.addEventListener 'mouseout', (e) ->
		bitmap = e.target
		bitmap.scaleX = bitmap.scaleY = bitmap.scale*(1/1.2)
	bitmap.addEventListener 'click', (e) ->
		console.log window.app.bitmaps
		bitmap = e.target
		window.app.bitmaps = []
		window.app.floating = false
		for child in window.app.stage.children
			if child != bitmap
				r = Math.random()
				s = 1
				if Math.random() < .5
					s = -1
				s2 = 1
				if Math.random() < .5
					s2 = -1
				createjs.Tween.get(child).to({
					x: window.app.canvas.width * 1.1 * Math.cos(r) * s
					y: window.app.canvas.width * 1.1 * Math.sin(r) * s2
					rotation: 720
					}, 1000, createjs.Ease.linear)
		createjs.Tween.get(bitmap).to({
			x: window.app.canvas.width / 2
			y: window.app.canvas.height / 2
			scaleX: window.app.canvas.width / bitmap.image.width
			scaleY: window.app.canvas.width / bitmap.image.width
			rotation: 0
			skewX: 0
			skewY: 90
			}, 1000, createjs.Ease.linear)
		setTimeout ( -> createBackground(bitmap) ), 1000

	window.app.stage.addChild(bitmap)
	randomizeProperties(bitmap)

createBackground = (bitmap) ->
	i = new Image()
	if bitmap.image.src.split("thumb_")[1]
		i.src = "/static/images/" + bitmap.image.src.split("thumb_")[1]
	else
		i.src = bitmap.image.src
	i.onload = (e) ->
		window.app.stage.removeAllChildren()
		b = new createjs.Bitmap(e.target)
		b.x = window.app.canvas.width / 2
		b.y = window.app.canvas.height / 2
		b.regX = b.image.width/2
		b.regY = b.image.height/2
		b.scaleX = b.scaleY = b.image.scale = window.app.canvas.width / b.image.width
		b.skewY = 90
		createjs.Tween.get(b).to({
		skewY: 0
		alpha: 0.3
		}, 1000, createjs.Ease.linear)
		window.app.stage.addChild(b)		
		$.getJSON "/find-by-id/" + bitmap.image.src.split("bldg")[1].split("x")[0], (response) ->
			# here we can display all the information about the building


randomizeProperties = (bitmap) ->
	if window.app.floating
		if bitmap.x + bitmap.image.width/2 * bitmap.scaleX > window.app.canvas.width or bitmap.x - bitmap.image.width/2 * bitmap.scaleX < 0
			bitmap.velocities.x = -bitmap.velocities.x * .7
			if bitmap.x - bitmap.image.width/2 * bitmap.scaleX < 0
				bitmap.x = bitmap.image.width/2 * bitmap.scaleX
			else
				bitmap.x = window.app.canvas.width - bitmap.image.width/2 * bitmap.scaleX
		if bitmap.y + bitmap.image.height/2 * bitmap.scaleX > window.app.canvas.height or bitmap.y - bitmap.image.height/2 * bitmap.scaleX < 0
			bitmap.velocities.y = -bitmap.velocities.y * .7
			if bitmap.y - bitmap.image.height/2 * bitmap.scaleX < 0
				bitmap.y = bitmap.image.height/2 * bitmap.scaleX
			else
				bitmap.y = window.app.canvas.height - bitmap.image.height/2 * bitmap.scaleX
		bitmap.velocities = {
			x: bitmap.velocities.x + _.random(-.02,.02)
			y: bitmap.velocities.y + _.random(-.02,.02)
		}
		createjs.Tween.get(bitmap).to({
			x: bitmap.x + bitmap.velocities.x
			y: bitmap.y + bitmap.velocities.y
			}, 10 * (Math.random() * .4 + .6), createjs.Ease.linear).call( -> randomizeProperties(bitmap))


tick = (event) ->
	# we do this on tick in case of a resize
	$("#canvas").attr 'width', document.width + "px"
	$("#canvas").attr 'height', (document.height - 75) + "px"
	context = window.app.canvas.getContext('2d')
	#all movement should be event.delta/1000 * pixelsPerSecond
	#window.app.stage.clear()
	for bitmapName in window.app.bitmaps
		bitmap = window.app.stage.getChildByName(bitmapName)
		if bitmap
			g = new createjs.Graphics()
			g.beginStroke("rgba(0,0,0,0.3)")
			.moveTo(window.app.canvas.width / 2,-100).setStrokeStyle(1, "round")
			.beginFill("#000").lineTo(bitmap.x, bitmap.y)
			.draw(context)
	window.app.stage.update()

$ ->
	init()
	window.app.first = true
	$("#search-bar").on 'keyup', (e) ->
		if e.which == 13
			Buildings.refresh()
