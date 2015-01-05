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

  _update_scene: ->
    if @levels[@level][@scene]['output']
      @$dialog.append("<div class='output'><p>#{@levels[@level][@scene]['output']}</p></div>")

  _init_console: ->
    # jQuery console
    @$console.console({
      promptLabel: '> '
      promptHistory: false
      historyPreserveColumn: false
      autofocus: true
      commandValidate: (line) =>
        if line is @levels[@level][@scene]['valid']
          @$dialog.append("<div class='input'><p>#{line}</p></div>")
          @scene++
          @_update_scene()
        else if line is ""
          return false
        else
          @$dialog.append("<div class='input'><p>#{line}</p></div>")
          @$dialog.append("<div class='output'><p>I don't understand that.</p></div>")

      commandHandle: (line) =>
        if line isnt ""
          @$dialog.append("<div class='input'><p>#{line}</p></div>")

    })

  _focus_console: ->
    @$body.on 'click', (ev) =>
      $inner = $('.jquery-console-inner')
      $typer = $('.jquery-console-typer')
      $inner.addClass 'jquery-console-focus'
      $typer.focus()

$ ->
  window.Levels = new Levels
