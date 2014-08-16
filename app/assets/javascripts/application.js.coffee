#= require jquery
#= require jquery_ujs
#= require_tree .

$ ->

  $("[data-api]").each ->
    e = $(this)
    api = e.data("api")
    argument = e.data("value-argument")
    extra = e.data("extra-arguments") || {}
    expr = e.data("value-expression")
    e.on "click change", ->
      if argument
        x = e.val()
        extra[argument] = if expr then eval(expr, x) else x
      $.post("1/#{api}", extra)

  objects = null
  player = null
  $("#map").on "click", (event) ->
    x = 100000 - event.offsetX * 200
    y = event.offsetY * 200
    $.post("/1/jump", x: x, z: y)
  renderObjects = () ->
    $.get "/1/data", (data) ->
      data = data
      player = data.player
      objects = data.objects
      c = $("#map canvas")[0].getContext("2d")
      c.save()
      c.scale(0.5, 0.5)
      c.clearRect(0, 0, 500, 500)
      c.save()
      c.strokeStyle = '#00f'
      for x in [0, 1, 2, 3, 4]
        for y in [0, 1, 2, 3, 4]
          c.strokeText("ABCDE"[y] + (x + 1), x * 100 + 5, y * 100 + 12)
          c.strokeRect(x * 100, y * 100, x * 100 + 100, y * 100 + 100)
      c.scale(1 / 200.0, 1 / 200.0)
      $.each objects, (_, obj) ->
        c.save();
        switch obj.type
          when 'player'
            c.strokeStyle = '#0f0'
          when 'base'
            c.strokeStyle = '#ff0'
          when 'nebula'
            c.strokeStyle = '#000'
          when 'asteroid'
            c.strokeStyle = '#660'
          when 'mine'
            c.strokeStyle = '#faa'
          when 'whale'
            c.strokeStyle = '#55c'
          when 'npc'
            if obj.ffi == 1
              c.strokeStyle = '#f00'
            else
              c.strokeStyle = '#cdc'
          else c.strokeStyle = '#fff'
        c.translate(100000 - obj.x, obj.z)
        c.scale(200.0, 200.0)
        c.strokeRect(-2, -2, 2, 2)
        c.restore();
      c.restore()
      c.restore()
      #setTimeout renderObjects, 500
  renderObjects()
  reloadPage = () ->
    $.get "/", (html) ->
      $("body").html(html)
      setTimeout reloadPage, 500
  #setTimeout reloadPage, 500
