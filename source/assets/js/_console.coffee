class Console

  constructor: ->
    # selectors
    @$document       = $(document)
    @$console        = $('.console')
    @$capture        = $('.console-capture')
    @$dialog         = $('.dialog')

    # variables
    @console_enabled = true
    @level           = window.Levels.level
    @scene           = window.Levels.scene
    @act             = window.Levels.act
    @level_data      = window.Levels.level_data

  init_dialog: ->
    message = @level_data[@level][@scene]['output']
    $el = $("<div class='console-output'></div>")
    @$dialog.append($el)
    @_typewriter(message, $el)

  init_console: ->
    @_focus_console()

    @$document.on 'click', (ev) =>
      @_focus_console()

    @$document.on 'keydown', (ev) =>
      if ev.keyCode is 13 and not @console_enabled
        ev.preventDefault()
        @_enable_console()

    @$capture.on 'keydown', (ev) =>
      line = @$capture.val()

      if ev.keyCode is 13
        ev.preventDefault()

        if line and line isnt ''
          message = @_validate_input(line)

          if message
            @_insert_output(message)
          else
            window.Levels.next_level()

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

    if @level_data[@level][@scene]['level-end'] and line is @level_data[@level][@scene]['valid']
      return false
    else if line is @level_data[@level][@scene]['valid']
      @scene++
      return @level_data[@level][@scene]['output']
    else
      return @level_data[@level][@scene]['reject']

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

      typewriter = =>
        timeout = setTimeout =>
          character++
          type = message.substring(0, character)
          $el.text(type)
          typewriter()

          if character is length
            @_enable_console()
        , 50

      typewriter()
    , 0

$ ->

  window.Console = new Console