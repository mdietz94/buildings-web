init = ->
	window.app = {}
	window.app.bitmaps = []
	window.app.canvas = document.getElementById("canvas")
	window.app.stage = new createjs.Stage(window.app.canvas)
	window.app.stage.enableMouseOver(50)
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
			bitmap.addEventListener 'mouseover', (e) ->
				bitmap = e.target
				bitmap.scaleX = bitmap.scaleY = bitmap.scale*1.2
			bitmap.addEventListener 'mouseout', (e) ->
				bitmap = e.target
				bitmap.scaleX = bitmap.scaleY = bitmap.scale*(1/1.2)

			window.app.bitmaps.push bitmap.name
			window.app.stage.addChild(bitmap)
			randomizeProperties(bitmap)
			break if i == 10
	window.app.g = new createjs.Shape()
	window.app.stage.addChild(window.app.g)
	createjs.Ticker.setFPS(30)
	createjs.Ticker.addEventListener 'tick', tick

	#for img in window.app.bitmaps
		
randomizeProperties = (bitmap) ->
	createjs.Tween.get(bitmap).to({
		x: window.app.canvas.width * .9 * Math.random()
		y: window.app.canvas.height * .9 * Math.random()
		rotation: 360 * .9 * Math.random()
		skewX: 30 * Math.random()
		skewY: 30 * Math.random()
		}, 10000 * (Math.random() * .4 + .6), createjs.Ease.linear).call( -> randomizeProperties(bitmap))


tick = (event) ->
	# all movement should be event.delta/1000 * pixelsPerSecond
		#window.app.g.graphics.beginPath.beginStroke("#444")
		#.moveTo(width/2,height/2).setStrokeStyle(2, "round")
		#.beginFill("#000").lineTo(img.x, img.y)
		#.closePath()
	window.app.stage.update()


$ ->
	$("#canvas").attr 'width', document.width
	$("#canvas").attr 'height', document.height
	init()