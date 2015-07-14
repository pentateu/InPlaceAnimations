angular
  .module('example')
  .controller 'ViewBController', ($scope, supersonic) ->

    supersonic.device.ready.then ->
      ##remove the loading
      setTimeout ->
        steroids.view.removeLoading()
      , 1000

    # I'm using the layer willchange to know when to change the webview contents
    # back again to
    eventHandler = steroids.layers.on 'willchange', (event) ->
      targetId = if event.target? and event.target.webview.id?
        event.target.webview.id
      else
        ""
      sourceId = if event.source? and event.source.webview.id?
        event.source.webview.id
      else
        ""
      console.log "layer willchange targetId: #{targetId} sourceId: #{sourceId}"


      # I need to know what other info you might need in the event
      # to identify that this is a pop or push and handle it accordinly
      window.location = "getting-started.html"

    $scope.popView = ->
      steroids.transitions.pop
        animation:
          transition: 'fade'
          duration: 0.7
          curve: 'easyOut'
