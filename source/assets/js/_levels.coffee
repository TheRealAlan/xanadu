class Levels

  constructor: ->
    @$body = $(document)
    @$console = $('.console')
    @$console_input = $('.jquery-console-prompt')
    @$dialog = $('.dialog')
    @level_files = [
      "/assets/js/_levels/level-1.coffee"
    ]

    @level = 0
    @scene = 0
    @act = 0

    @levels = [
      [
        title: "Scene 1"
        output: "Middleman is distributed using the RubyGems package manager. This means you will need both the Ruby language runtime installed and RubyGems to begin using Middleman."
        valid: "walk"
      ,
        title: "Scene 2"
        output: "Mac OS X comes prepackaged with both Ruby and Rubygems, however, some of the Middleman's dependencies need to be compiled during installation and on OS X that requires Xcode. Xcode can be installed via the Mac App Store. Alternately, if you have a free Apple Developer account, you can just install Command Line Tools for Xcode from their downloads page."
        valid: "die"
      ,
        title: "Scene 3"
        output: "No, you die."
        valid: ""
      ]
    ]

    @_update_scene()
    @_init_console()
    @_focus_console()

  _update_scene: ->

    @$dialog.append("<div class='output'><p>#{@levels[@level][@scene]['output']}</p></div>")
    console.log(@levels[@level][@scene]['valid'])

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
