angular
  .module('example')
  .controller 'StartController', ($scope, supersonic) ->

    $ = (query) -> document.querySelector(query)

    viewBNavBar = ->
      homeButton = new steroids.buttons.NavigationBarButton
      #homeButton.imagePath = "/icons/home.svg"
      homeButton.title = "..."
      homeButton.onTap = => navigator.notification.alert "Go Home!"

      {
        title: "Second View (B)"
        buttons:
          right: [homeButton]
      }

    updateView = ->
      if displayedView == "A"
        showViewA()
      else
        showViewB()

    listenLayersEvents = ->
      console.log "%%%% listenLayersEvents()"
      #im using the willchange event to know when to change views
      # and remove the static container
      eventHandler = steroids.layers.on 'willchange', (event) ->
        console.log "%%%% layers.on willchange -> event.type: #{event.type}"
        updateView()

        if event.type == "pop"
          removeStaticContainer()

        steroids.layers.off 'willchange', eventHandler

    removeStaticContainer = ->
      setTimeout ->
        steroids.transitions.removeStaticContainer {},
          onSuccess: -> console.log "%%%% removeStaticContainer -> onSuccess()"
          onFailure: -> console.log "%%%% removeStaticContainer -> onFailure()"
      , 1000

    displayedView = "A"
    showViewA = ->
      console.log "%%%% showViewA()"
      $("#viewA").classList.remove('hidden')
      $("#viewB").classList.add('hidden')

    showViewB = ->
      console.log "%%%% showViewB()"
      $("#viewA").classList.add('hidden')
      $("#viewB").classList.remove('hidden')

    $scope.popView = ->
      params =
        animation:
          transition: 'fade'
          duration: 0.7
          curve: 'easyOut'

      steroids.transitions.pop params,
        onSuccess: ->
          console.log "%%%% popView() onSuccess()"

          #Do the UI changes in the webview while it is still covered by the
          #"static container"
          displayedView = "A"
          updateView()

        ,
        onFailure: -> console.log "%%%% popView() onFailure()"

    $scope.addButton = ->
      button = new steroids.buttons.NavigationBarButton
      button.title = "TEST"
      button.onTap = => navigator.notification.alert "RIGHT BUTTON TAPPED"

      steroids.view.navigationBar.setButtons {
        right: [button]
      },
        onSuccess: => steroids.logger.log "SUCCESS in setting one button into nav bar (legacy)"
        onFailure: => navigator.notification.alert "FAILURE in testSetButtonsWithOneRightButton (legacy)"

    $scope.testLog = ->
      console.log "%%%% testLog()"

    $scope.pushView = ->

      console.log "%%%% pushView()"

      params =
        animation:
          transition: "slideFromRight"
          duration: 0.5
          curve: "easeInOut"
        navigationBar:viewBNavBar()

      steroids.transitions.push params,
        onSuccess: ->
          console.log "%%%% pushView() onSuccess()"

          #change the UI while the loading view is being displayed
          displayedView = "B"
          updateView()

          listenLayersEvents()

          ##remove the loading
          setTimeout ->
            displayedView = "A"
            steroids.view.removeLoading()
          , 1000

        ,
        onFailure: -> console.log "%%%% pushView() onFailure()"
