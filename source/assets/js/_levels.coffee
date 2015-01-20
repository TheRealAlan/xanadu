class Levels

  constructor: ->
    # selectors
    @$body           = $(document)
    @$console        = $('.console')
    @$capture        = $('.console-capture')
    @$dialog         = $('.dialog')

    # variables
    @console_enabled = true
    @level           = 0
    @scene           = 0
    @act             = 0

    # levels
    @levels          = []
    @level_paths     = [
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
          @_init_dialog()
          @_init_console()

  _init_dialog: ->
    message = @levels[@level][@scene]['output']
    $el = $("<div class='console-output'></div>")
    @$dialog.append($el)
    @_typewriter(message, $el)

  _init_console: ->
    @_focus_console()

    @$body.on 'click', (ev) =>
      @_focus_console()

    @$body.on 'keydown', (ev) =>
      if ev.keyCode is 13 and not @console_enabled
        ev.preventDefault()
        @_enable_console()

    @$capture.on 'keydown', (ev) =>
      line = @$capture.val()

      if ev.keyCode is 13
        ev.preventDefault()

        if line and line isnt ''
          message = @_validate_input(line)
          @_insert_output(message)

  _disable_console: ->
    @console_enabled = false
    @$capture.hide()

  _enable_console: ->
    clearTimeout @_typewriter.timeout
    @console_enabled = true
    @$capture.show()
    @_focus_console()

  _validate_input: (line) ->
    @_insert_input()
    @_reset_console()
    @_scroll_to_bottom()

    if line is @levels[@level][@scene]['valid']
      @scene++
      return @levels[@level][@scene]['output']
    else
      return @levels[@level][@scene]['reject']

  _insert_input: ->
    message = @$capture.val()

    if message and message isnt ''
      $el = $("<div class='console-input'>#{message}</div>")
      @$dialog.append($el)

  _insert_output: (message) ->
    $el = $("<div class='console-output'></div>")
    @$dialog.append($el)
    @_typewriter(message, $el)

  _focus_console: ->
    @$capture.focus()

  _reset_console: ->
    @$capture.val('')

  _scroll_to_bottom: ->
    @$console.velocity 'scroll',
      duration: 200

  _typewriter: (message, $el) ->
    delay = setTimeout =>
      length = message.length
      character = 0
      timeout = null
      @_disable_console()

      typewriter = ->
        timeout = setTimeout ->
          character++
          type = message.substring(0, character)
          $el.text(type)
          typewriter()

          if character is length
            window.Levels._enable_console()
        , 50

      typewriter()
    , 0

$ ->

  window.Levels = new Levels
