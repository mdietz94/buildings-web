init = ->
	window.app = {}
	window.app.bitmaps = []
	window.app.canvas = document.getElementById("canvas")
	window.app.stage = new createjs.Stage(window.app.canvas)
	window.app.stage.enableMouseOver(50)
	window.app.floating = true
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


	#for img in window.app.bitmaps

handleImageLoad = (e) ->
	console.log e
	bitmap = new createjs.Bitmap(e.target)
	console.log bitmap.image.height
	bitmap.regX = bitmap.image.width/2|0
	bitmap.regY = bitmap.image.height/2|0
	bitmap.scaleX = bitmap.scaleY = bitmap.scale = 128.0 / bitmap.image.width
	#bitmap.name = filename
	bitmap.rotation = _.random(-10,10)
	bitmap.velocities = {x: 0, y: 0 }
	bitmap.addEventListener 'mouseover', (e) ->
		bitmap = e.target
		bitmap.scaleX = bitmap.scaleY = bitmap.scale*1.2
	bitmap.addEventListener 'mouseout', (e) ->
		bitmap = e.target
		bitmap.scaleX = bitmap.scaleY = bitmap.scale*(1/1.2)
	bitmap.addEventListener 'click', (e) ->
		bitmap = e.target
		window.app.floating = false
		for child in window.app.stage.children
			if child != bitmap
				createjs.Tween.get(child).to({
					x: window.app.canvas.width * 1.1
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

	window.app.bitmaps.push bitmap.name
	window.app.stage.addChild(bitmap)
	randomizeProperties(bitmap)

createBackground = (bitmap) ->
	i = new Image()
	i.src = "/static/images/" + bitmap.image.src.split("thumb_")[1]
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
		}, 1000, createjs.Ease.linear)
		window.app.stage.addChild(b)


randomizeProperties = (bitmap) ->
	if window.app.floating
		if bitmap.x + bitmap.image.width > window.app.canvas.width or bitmap.x - bitmap.image.width < 0
			bitmap.velocities.x = -bitmap.velocities.x * .7
			if bitmap.x - bitmap.image.width < 0
				bitmap.x = bitmap.image.width
			else
				bitmap.x = window.app.canvas.width - bitmap.image.width
		if bitmap.y + bitmap.image.height > window.app.canvas.height or bitmap.y - bitmap.image.height < 0
			bitmap.velocities.y = -bitmap.velocities.y * .7
			if bitmap.y - bitmap.image.height < 0
				bitmap.y = bitmap.image.height
			else
				bitmap.y = window.app.canvas.height - bitmap.image.height
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
	window.app.stage.update()
	#context = window.app.canvas.getContext('2d')
	#all movement should be event.delta/1000 * pixelsPerSecond
	#for bitmapName in window.app.bitmaps
	#	bitmap = window.app.stage.getChildByName(bitmapName)
	#	g = new createjs.Graphics()
	#	g.beginStroke("rgba(0,0,0,0.5)")
	#	.moveTo(100,100).setStrokeStyle(1, "round")
	#	.beginFill("#000").lineTo(bitmap.x, bitmap.y)
	#	.draw(context)


$ ->
	init()