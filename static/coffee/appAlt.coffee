#	
# Just in general sloppy code, needs rewrite, like for instance, we should only be ticking when things change
# not a big deal for the moment but huge for deployment
#

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
	window.app.loading = false
	window.app.bitmaps = []
	window.app.canvas = document.getElementById("canvas")
	window.app.stage = new createjs.Stage(window.app.canvas)
	window.app.stage.enableMouseOver(50)
	window.app.stage.autoClear = false
	window.app.parallax = {dx: 0, dy: 0}
	window.app.stage.addEventListener 'stagemousemove', (e) ->
		window.app.parallax.dx = window.app.canvas.width / 2 - e.stageX
		window.app.parallax.dy = window.app.canvas.height / 2 - e.stageY
	window.app.floating = true
	Buildings.on 'reset', refresh
	bg = new Image()
	bg.src = "/static/images/bldg0x0.jpg"
	bg.onload = (e) ->
		bitmap = new createjs.Bitmap(e.target)
		bitmap.regX = bitmap.image.width / 2
		bitmap.regY = bitmap.image.height / 2
		bitmap.scaleX = bitmap.scaleY = bitmap.image.scale = 2 * document.width / bitmap.image.width
		bitmap.x = bitmap.oX = document.width / 2
		bitmap.y = bitmap.oY = document.height / 2
		bitmap.alpha = .3
		bitmap.parallaxFactor = .1
		bitmap.name = 'bg'
		window.app.stage.addChild(bitmap)
		window.app.bitmaps.push(bitmap.name)
	$.getJSON "/static/images", (r) ->
		files = r['files'].filter((f) -> f.match("thumb_bldg") )
		i = 0
		x = 64 + 10
		y = 64 + 10
		filename = undefined
		for i in [0..20]
			filename = files[_.random(files.length)]
			while filename == undefined
				filename = files[_.random(files.length)]
				console.log filename
			img = new Image()
			img.src = "/static/images/" + filename
			( (xx,xy) -> img.onload = ( (e) -> handleImageLoad(e,filename.split("bldg")[1].split("x")[0], xx, xy)) )(x,y)
			x += 128 + 10
			if x > document.width
				x = 64 + 10
				y += 128 + 10
	createjs.Ticker.setFPS(30)
	createjs.Ticker.addEventListener 'tick', tick

refresh = ->
	# to do anything meaningful we need to know how many there are
	# and that way we can scale all pictures so that they will fit + margin
	# but we also need to be mindful about pictures that already exist

	# we should probably move those to the top left and then we'll know what our
	# x and y are for when we start adding new buildings

	# also clearly we need a threshold size after which we add detailed information
	# the thumbnails are great for when there will be a ton of them though
	ids = Buildings.models.map( (m) -> "#{m.get('id')}" )
	num = ids.length
	aspectRatio = window.app.canvas.width / window.app.canvas.height
	# if aspectRatio were 2, we'd want twice as many columns as rows
	# and we would know that numberOfRows * aspectRatio = numberOfColumns (with some usage of Math.floor)
	# and the number of images total is equal to numberOfRows * numberOfColumns
	# so if we have the total number of images and the aspect ratio, we have
	#  num = numberOfRows * numberOfRows * aspectRatio
	#  numberOfRows = Math.ceil(Math.sqrt(num / aspectRatio)) # because an extra row never killed, but one too few did once
	#  numberOfColumns = Math.ceil(numberOfRows * aspectRatio)
	# This makes the average image size the canvas height divided by the number of rows, and the width the same for columns
	# though because we accounted for the aspect ratio, this should basically be the same number, we'll just pick the smaller.
	#  b.scaleX = b.scaleY = b.image.scale = img_max_size / Math.max(b.image.width, b.image.height)
	numberOfRows = Math.ceil(Math.sqrt(num / aspectRatio))
	numberOfCols = Math.ceil(num / numberOfRows)
	console.log "Nums: #{num}"
	console.log "Rows: #{numberOfRows}"
	console.log "Cols: #{numberOfCols}"
	img_size_and_margins = Math.floor(Math.min(window.app.canvas.width / numberOfCols, window.app.canvas.height / numberOfRows))
	margin = 5
	img_size = img_size_and_margins - margin
	console.log "Size: #{img_size}"
	toRemove = []
	cx = img_size / 2 + margin
	cy = img_size / 2 + margin
	for child in window.app.stage.children
		n = child.name.split("bldg")[1]
		if n
			n = n.split("x")[0]
			if ids.indexOf(n) < 0
				createjs.Tween.get(child).to({skewX: 90}, 1000, createjs.Ease.linear)
				toRemove.push child
			else
				child.oX = cx
				child.oY = cy
				createjs.Tween.get(child).to({
					x: cx
					y: cy
					scaleX: img_size / Math.max(child.image.height,child.image.width)
					scaleY: img_size / Math.max(child.image.height,child.image.width)}, 1000, createjs.Ease.linear)
				cx += img_size_and_margins
				if cx > window.app.canvas.width
					cx = img_size / 2 + margin
					cy += img_size_and_margins

	$.getJSON "/static/images", (r) ->
		files = r['files']
		children = window.app.stage.children.map((c) ->
			c = c.name.split("bldg")[1]
			if c
				return c.split("x")[0]
			undefined )
		console.log "Size: #{img_size}"
		for id in ids
			if children.indexOf("#{id}") < 0
				img = new Image()
				if "bldg" + id + "x0.jpg" in files
					img.src = "/static/images/thumb_bldg" + id + "x0.jpg"
				else
					img.src = "/static/images/thumb_bldg0x0.jpg"
				((i, xx, xy, xsize) ->
					img.onload = (e) -> handleImageLoad(e, i, xx, xy, xsize)
				)(id, cx, cy, img_size)
				cx += img_size_and_margins
				if cx > window.app.canvas.width
					cx = img_size / 2 + margin
					cy += img_size_and_margins
	((toRemove) ->
		setTimeout(( ->
			for r in toRemove
				window.app.stage.removeChild(r)
		), 1000)
	)(toRemove)


handleImageLoad = (e, id, x, y, img_size) ->
	bitmap = new createjs.Bitmap(e.target)
	bitmap.x = bitmap.oX = x|0
	bitmap.y = bitmap.oY = y|0
	bitmap.regX = bitmap.image.width / 2
	bitmap.regY = bitmap.image.height / 2
	if img_size > 0
		sz = img_size
	else
		sz = 128
	bitmap.scaleX = bitmap.scaleY = bitmap.image.scale = sz / Math.max(bitmap.image.height,bitmap.image.width)
	if id
		bitmap.name = "/static/images/bldg" + id + "x0.jpg"
	else
		bitmap.name = bitmap.image.src
	bitmap.parallaxFactor = 0.02
	bitmap.rotation = 0
	bitmap.velocities = {x: 0, y: 0 }
	bitmap.shadow = new createjs.Shadow("#000000", 0, 0, 8);
	bitmap.skewX = 90
	setTimeout( ( -> createjs.Tween.get(bitmap).to({ skewX: 0 }, 1000, createjs.Ease.linear) ), 1000 )
	bitmap.addEventListener 'mouseover', (e) ->
		bitmap = e.target
		bitmap.scaleX = bitmap.scaleY = bitmap.image.scale = bitmap.image.scale*1.2
	bitmap.addEventListener 'mouseout', (e) ->
		bitmap = e.target
		bitmap.scaleX = bitmap.scaleY = bitmap.image.scale = bitmap.image.scale*(1/1.2)
	bitmap.addEventListener 'click', (e) ->
		bitmap = e.target
		window.app.bitmaps = []
		window.app.floating = false
		for child in window.app.stage.children
			if child.name == 'bg'
				( (child) -> createjs.Tween.get(child).to({alpha: 0}, 2000, createjs.Ease.linear).call( -> window.app.stage.removeChild(child)))(child)
			else if child != bitmap
				r = Math.random()
				s = 1
				if Math.random() < .5
					s = -1
				s2 = 1
				if Math.random() < .5
					s2 = -1
				( (child) -> createjs.Tween.get(child).to({
					x: window.app.canvas.width * 1.1 * Math.cos(r) * s
					y: window.app.canvas.width * 1.1 * Math.sin(r) * s2
					rotation: 720
					}, 1000, createjs.Ease.linear).call( -> window.app.stage.removeChild(child)))(child)
		createjs.Tween.get(bitmap).to({
			x: window.app.canvas.width / 2
			y: window.app.canvas.height / 2
			scaleX: window.app.canvas.width / bitmap.image.width * 1.2
			scaleY: window.app.canvas.width / bitmap.image.width * 1.2
			rotation: 0
			skewX: 0
			skewY: 90
			}, 1000, createjs.Ease.linear)
		setTimeout ( -> createBackground(bitmap) ), 1000
	window.app.stage.addChild(bitmap)
	#randomizeProperties(bitmap)

createBackground = (bitmap) ->
	i = new Image()
	if bitmap.image.src.split("thumb_")[1]
		i.src = "/static/images/" + bitmap.image.src.split("thumb_")[1]
	else
		i.src = bitmap.image.src
	i.onload = (e) ->
		window.app.loading = true
		b = new createjs.Bitmap(e.target)
		b.x = b.oX = window.app.canvas.width / 2
		b.y = b.oY = window.app.canvas.height / 2
		b.regX = b.image.width/2
		b.regY = b.image.height/2
		b.parallaxFactor = .1
		b.rotation = 0
		b.scaleX = b.scaleY = b.image.scale = window.app.canvas.width * 1.2 / b.image.width
		b.skewY = 90
		b.skewX = 0
		b.name = 'bg'
		createjs.Tween.get(b).to({
		skewY: 0
		alpha: 0.3
		}, 1000, createjs.Ease.linear)
		window.app.stage.addChild(b)
		#$.getJSON "/find-by-id/" + bitmap.image.src.split("bldg")[1].split("x")[0], (response) ->
			# here we can display all the information about the building


randomizeProperties = (bitmap) ->
	window.app.floating = false
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
	window.app.stage.clear()
	if not window.app.loading
		for bitmap in window.app.stage.children
			#if bitmap.name != 'bg'
			#	g = new createjs.Graphics()
			#	g.beginStroke("rgba(0,0,0,0.3)")
			#	.setStrokeStyle(1, "round")
			#	.beginFill("#000").drawRect(bitmap.x - bitmap.image.width*.6 * bitmap.scaleX, bitmap.y - bitmap.image.height*.6 *bitmap.scaleY,bitmap.image.width * bitmap.scaleX * 1.2, bitmap.image.height *bitmap.scaleY * 1.2)
			#	.draw(context)
			if bitmap.shadow
				createjs.Tween.get(bitmap.shadow).to({
					offsetX: window.app.parallax.dx * bitmap.parallaxFactor / 10
					offsetY: window.app.parallax.dy * bitmap.parallaxFactor / 10
					}, 10, createjs.Ease.linear)
			createjs.Tween.get(bitmap).to({
				x: bitmap.oX + window.app.parallax.dx * bitmap.parallaxFactor
				y: bitmap.oY + window.app.parallax.dy * bitmap.parallaxFactor
				}, 10, createjs.Ease.linear).call( -> randomizeProperties(bitmap))
	window.app.stage.update()

$ ->
	init()
	window.app.first = true
	$("#search-bar").on 'keyup', (e) ->
		if e.which == 13
			Buildings.refresh()
