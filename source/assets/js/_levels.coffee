class Levels

  constructor: ->
    @$body = $(document)
    @$console = $('.console')
    @$console_input = $('.jquery-console-prompt')
    @$dialog = $('.dialog')

    @level = 0
    @scene = 0
    @act = 0

    @levels = []
    @level_paths = [
      "/levels/level-01.json"
      "/levels/level-02.json"
    ]

    @level_count = 0

    for level in @level_paths
      $.getJSON level, (data) =>
        @levels.push data
      .fail (err) =>
        "Request failed: #{err}"
      .done (data) =>
        @level_count++
        if @level_count is @level_paths.length
          # Loading finished, init
          @_update_scene()
          @_init_console()
          @_focus_console()
          @_typewriter()

  _update_scene: ->
    @$dialog.append("<div class='jquery-console-message'>#{@levels[@level][@scene]['output']}</div>")

  _init_console: ->

    # jQuery console
    @$console.console({
      promptLabel: '> '
      promptHistory: false
      historyPreserveColumn: false
      autofocus: true

      commandHandle: (line) =>
        @_scroll_to_bottom()
        @_typewriter()
        @_handle_input(line)

    })

  _focus_console: ->
    @$body.on 'click', (ev) =>
      $inner = $('.jquery-console-inner')
      $typer = $('.jquery-console-typer')
      $inner.addClass 'jquery-console-focus'
      $typer.focus()

  _handle_input: (line) ->
    if line is @levels[@level][@scene]['valid']
      @scene++
      return @levels[@level][@scene]['output']
    else
      return "Nope."

  _scroll_to_bottom: ->
    $prompt = $('.jquery-console-prompt-box:last')
    $prompt.velocity( 'scroll', {
      duration: 200
    })

  _typewriter: (text, $target) ->
    delay = setTimeout ->
      $target = $('.jquery-console-message:last')
      text = $target.text()
      length = text.length
      character = 0
      timeout = null
      $target.text('')

      typewriter = ->
        timeout = setTimeout ->
          character++
          type = text.substring(0, character)
          $target.text type
          typewriter()

          if character is length
            clearTimeout timeout
        , 50

      typewriter()
    , 0

$ ->

  window.Levels = new Levels
