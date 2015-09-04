angular
  .module('example')
  .controller 'StartController', ($scope, supersonic) ->

    $ = (query) -> document.querySelector(query)

    myUUID = null

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
        console.log "%%%% displayedView - will show A"
        showViewA()
      else
        console.log "%%%% displayedView - will show B"
        showViewB()


    ###
    steroids.layers.on 'willchange', (event) ->
      console.log "%%%% willchange - event event.type: #{JSON.stringify(event.type)}"

    steroids.layers.on 'didchange', (event) ->
      console.log "%%%% didchange - event event.type: #{JSON.stringify(event.type)}"
    ###

    isMyEvent = (event) -> event.type.indexOf("Transition") > -1 && event.target.webview.uuid == myUUID

    listenLayersEvents = ->
      console.log "%%%% listen to layer will change"
      #im using the willchange event to know when to change views
      # and remove the static container
      eventHandler = steroids.layers.on 'willchange', (event) ->
        console.log "%%%% layers.on willchange -> event.type: #{JSON.stringify(event.type)}"
        return unless isMyEvent event

        console.log "%%%% layers.on willchange -> IT IS ME :)"
        updateView()

        if event.type == "Transition-Pop"
          removeStaticContainer()

        steroids.layers.off 'willchange', eventHandler

    removeStaticContainer = ->
      console.log "%%%% listen to layer did change"
      eventHandler = steroids.layers.on 'didchange', (event) ->
        console.log "%%%% layers.on didchange -> event.type: #{JSON.stringify(event.type)}"
        return unless isMyEvent event

        steroids.transitions.removeStaticContainer {},
          onSuccess: -> console.log "%%%% removeStaticContainer -> onSuccess()"
          onFailure: (error) -> console.log "%%%% removeStaticContainer -> onFailure() error: #{JSON.stringify(error)}"

        steroids.layers.off 'didchange', eventHandler

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

      steroids.view.navigationBar.update {
        buttons:
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
        onSuccess: (webviewInfo)->
          console.log "%%%% pushView() onSuccess() - webviewInfo: #{JSON.stringify(webviewInfo)}"

          myUUID = webviewInfo.uuid

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
