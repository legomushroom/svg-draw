segment     = false 
path        = false
movePath    = false
connector   = null
currentItem = null

hitOptions =
  stroke: true
  tolerance: 5

App.backgroundLayer = new Layer()
App.mainLayer =       new Layer()


class Paths
  backgroundRects: []
  clearGrid:->
    for rect in @backgroundRects
      rect.remove()

  refreshGrid:->
    console.time 'refresh grid'
    App.backgroundLayer.activate()
    @clearGrid()
    for line, j in App.grid
      # console.log line
      for cell, i in line
        if cell isnt 0
          x = i*App.gs; y = j*App.gs
          rectangle = new Rectangle(new Point(x, y), new Point(x+App.gs, y+App.gs))
          rect = new Path.Rectangle rectangle
          rect.fillColor = 'red'
          rect.opacity = .05
          rect.isBackground = true
          @backgroundRects.push rect


    App.mainLayer.activate()
    console.timeEnd 'refresh grid'

App.paths = new Paths


onMouseDown = (event) ->
  return if App.main.tool isnt 'path'
  if !currentItem
    if !connector
      connector = new Path; connector.strokeWidth = 4; connector.strokeColor = 'black'

    coords = App.helpers.getNearestCellCenter event.point
    if App.helpers.grid.isFreeCell coords
      connector.add new Point coords
      App.helpers.grid.holdCellXY coords, connector

onMouseDrag = (event) ->
  coords = App.helpers.getNearestCellCenter event.point
  if currentItem
    currentItem.position += event.delta
  else if connector and App.helpers.grid.isFreeCell coords
    console.log 'free'
    connector.add new Point coords
    App.helpers.grid.holdCellXY coords, connector


onMouseUp = (event) ->
  connector = null
  if currentItem
    coords = App.helpers.getNearestCellCenter currentItem.bounds
    coords.x += (currentItem.bounds.width/2)
    coords.y += (currentItem.bounds.height/2)
    currentItem.position = coords
    App.helpers.grid.reposit currentItem

onMouseMove = (event) ->
  project.activeLayer.selected = false
  if event.item and  not event.item.isBackground
    event.item.selected = true
    currentItem = event.item
  else currentItem = false

onFrame = (e)->











# values =
#   paths: 50
#   minPoints: 5
#   maxPoints: 15
#   minRadius: 30
#   maxRadius: 90

# createPaths = ->
#   radiusDelta = values.maxRadius - values.minRadius
#   pointsDelta = values.maxPoints - values.minPoints
#   i = 0

#   while i < values.paths
#     radius = values.minRadius + Math.random() * radiusDelta
#     points = values.minPoints + Math.floor(Math.random() * pointsDelta)
#     path = createBlob(view.size * Point.random(), radius, points)
#     lightness = (Math.random() - 0.5) * 0.4 + 0.4
#     hue = Math.random() * 360
#     path.fillColor =
#       hue: hue
#       saturation: 1
#       lightness: lightness

#     path.strokeColor = "black"
#     i++
# createBlob = (center, maxRadius, points) ->
#   path = new Path()
#   path.closed = true
#   i = 0

#   while i < points
#     delta = new Point(
#       length: (maxRadius * 0.5) + (Math.random() * maxRadius * 0.5)
#       angle: (360 / points) * i
#     )
#     path.add center + delta
#     i++
#   path.smooth()
#   path


