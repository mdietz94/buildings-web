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
		for filename in files
			i += 1
			bitmap = new createjs.Bitmap("/static/images/" + filename)
			console.log bitmap.image.height
			bitmap.x = window.app.canvas.width * .9 * Math.random() | 0
			bitmap.y = window.app.canvas.height * .9 * Math.random() | 0
			bitmap.rotation = 360 * Math.random() | 0
			bitmap.regX = bitmap.image.width/2|0
			bitmap.regY = bitmap.image.height/2|0
			bitmap.scaleX = bitmap.scaleY = bitmap.scale = 128.0 / bitmap.image.width
			bitmap.name = filename
			bitmap.velocities = {x: 0, y: 0, rotation: 0, skewX: 0, skewY: 0}
			bitmap.addEventListener 'mouseover', (e) ->
				bitmap = e.target
				bitmap.scaleX = bitmap.scaleY = bitmap.scale*1.2
			bitmap.addEventListener 'mouseout', (e) ->
				bitmap = e.target
				bitmap.scaleX = bitmap.scaleY = bitmap.scale*(1/1.2)
			bitmap.addEventListener 'click', (e) ->
				bitmap = e.target
				for child in window.app.stage.children
					if child != bitmap
						window.app.floating = false
						createjs.Tween.get(child).to({
							x: window.app.canvas.width * 1.1
							y: window.app.canvas.height * 1.1
							rotation: 720
							}, 3000, createjs.Ease.linear)
			window.app.bitmaps.push bitmap.name
			window.app.stage.addChild(bitmap)
			randomizeProperties(bitmap)
			break if i == 10
	createjs.Ticker.setFPS(30)
	createjs.Ticker.addEventListener 'tick', tick

	#for img in window.app.bitmaps

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
		bitmap.rotation %= 360
		if bitmap.velocities.rotation > 10 or bitmap.velocities.rotation < -10
			bitmap.velocities.rotation *= .9
		if bitmap.skewX < -10 or bitmap.skewX > 10
			bitmap.velocities.skewX = -bitmap.velocities.skewX * .5
		if bitmap.skewY > 10 or bitmap.skewY < -10
			bitmap.velocities.skewY = -bitmap.velocities.skewY * .5
		bitmap.velocities = {
			x: bitmap.velocities.x + _.random(-.5,.5)
			y: bitmap.velocities.y + _.random(-.5,.5)
			rotation: bitmap.velocities.rotation + _.random(-.5,.5)
			skewX: bitmap.velocities.skewX + _.random(-.5,.5)
			skewY: bitmap.velocities.skewY + _.random(-.5,.5)
		}
		createjs.Tween.get(bitmap).to({
			x: bitmap.x + bitmap.velocities.x
			y: bitmap.y + bitmap.velocities.y
			rotation: bitmap.rotation + bitmap.velocities.rotation
			skewX: bitmap.skewX + bitmap.velocities.skewX
			skewY: bitmap.skewY + bitmap.velocities.skewY
			}, 250 * (Math.random() * .4 + .6), createjs.Ease.linear).call( -> randomizeProperties(bitmap))


tick = (event) ->
	window.app.stage.update()
	context = window.app.canvas.getContext('2d')
	#all movement should be event.delta/1000 * pixelsPerSecond
	#for bitmapName in window.app.bitmaps
	#	bitmap = window.app.stage.getChildByName(bitmapName)
	#	g = new createjs.Graphics()
	#	g.beginStroke("rgba(0,0,0,0.5)")
	#	.moveTo(100,100).setStrokeStyle(1, "round")
	#	.beginFill("#000").lineTo(bitmap.x, bitmap.y)
	#	.draw(context)


$ ->
	$("#canvas").attr 'width', document.width + "px"
	$("#canvas").attr 'height', (document.height - 75) + "px"
	init()