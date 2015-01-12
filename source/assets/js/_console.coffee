(($) ->
  isWebkit = !!~navigator.userAgent.indexOf(" AppleWebKit/")
  $.fn.console = (config) ->

    keyCodes = {}
    ctrlCodes = {}
    altCodes = {}
    shiftCodes = 13: newLine
    cursor = "<span class=\"jquery-console-cursor\">&nbsp;</span>"
    container = $(this)
    inner = $("<div class=\"jquery-console-inner\"></div>")
    typer = $("<textarea class=\"jquery-console-typer\"></textarea>")
    promptBox = ''
    prompt = ''
    continuedPromptLabel = (if config and config.continuedPromptLabel then config.continuedPromptLabel else "> ")
    column = 0
    promptText = ""
    restoreText = ""
    continuedText = ""
    fadeOnReset = (if config.fadeOnReset isnt `undefined` then config.fadeOnReset else true)
    history = []
    ringn = 0
    cancelKeyPress = 0
    acceptInput = true
    cancelCommand = false
    extern = {}

    # Make a new prompt box
    newPromptBox = ->
      column = 0
      promptText = ""
      ringn = 0 # Reset the position of the history ring
      enableInput()
      promptBox = $("<div class=\"jquery-console-prompt-box\"></div>")
      label = $("<span class=\"jquery-console-prompt-label\"></span>")
      labelText = (if extern.continuedPrompt then continuedPromptLabel else extern.promptLabel)
      promptBox.append label.text(labelText).show()
      label.html label.html().replace(" ", "&nbsp;")
      prompt = $("<span class=\"jquery-console-prompt\"></span>")
      promptBox.append prompt
      inner.append promptBox
      updatePromptDisplay()
      return

    #//////////////////////////////////////////////////////////////////////
    # Handle setting focus

    # Don't mess with the focus if there is an active selection

    #//////////////////////////////////////////////////////////////////////
    # Handle losing focus

    #//////////////////////////////////////////////////////////////////////
    # Bind to the paste event of the input box so we know when we
    # get pasted data

    # wipe typer input clean just in case

    # this timeout is required because the onpaste event is
    # fired *before* the text is actually pasted

    #//////////////////////////////////////////////////////////////////////
    # Handle key hit before translation
    # For picking up control characters like up/left/down/right

    # C-c: cancel the execution

    #//////////////////////////////////////////////////////////////////////
    # Handle key press

    # C-v: don't insert on paste event
    isIgnorableKey = (e) ->

      # for now just filter alt+tab that we receive on some platforms when
      # user switches windows (goes away from the browser)
      (e.keyCode is keyCodes.tab or e.keyCode is 192) and e.altKey

    # Rotate through the command history
    rotateHistory = (n) ->
      return  if history.length is 0
      ringn += n
      if ringn < 0
        ringn = history.length
      else ringn = 0  if ringn > history.length
      prevText = promptText
      if ringn is 0
        promptText = restoreText
      else
        promptText = history[ringn - 1]
      if config.historyPreserveColumn
        if promptText.length < column + 1
          column = promptText.length
        else column = promptText.length  if column is 0
      else
        column = promptText.length
      updatePromptDisplay()
      return
    previousHistory = ->
      rotateHistory -1
      return
    nextHistory = ->
      rotateHistory 1
      return

    # Add something to the history ring
    addToHistory = (line) ->
      history.push line
      restoreText = ""
      return

    # Delete the character at the current position
    deleteCharAtPos = ->
      if column < promptText.length
        promptText = promptText.substring(0, column) + promptText.substring(column + 1)
        restoreText = promptText
        true
      else
        false
    backDelete = ->
      if moveColumn(-1)
        deleteCharAtPos()
        updatePromptDisplay()
      return
    forwardDelete = ->
      updatePromptDisplay()  if deleteCharAtPos()
      return
    deleteUntilEnd = ->
      updatePromptDisplay()  while deleteCharAtPos()
      return
    deleteNextWord = ->

      # A word is defined within this context as a series of alphanumeric
      # characters.
      # Delete up to the next alphanumeric character
      while column < promptText.length and not isCharAlphanumeric(promptText[column])
        deleteCharAtPos()
        updatePromptDisplay()

      # Then, delete until the next non-alphanumeric character
      while column < promptText.length and isCharAlphanumeric(promptText[column])
        deleteCharAtPos()
        updatePromptDisplay()
      return
    newLine = ->
      lines = promptText.split("\n")
      last_line = lines.slice(-1)[0]
      spaces = last_line.match(/^(\s*)/g)[0]
      new_line = "\n" + spaces
      promptText += new_line
      moveColumn new_line.length
      updatePromptDisplay()
      return

    # Validate command and trigger it if valid, or show a validation error
    commandTrigger = ->
      line = promptText
      if typeof config.commandValidate is "function"
        ret = config.commandValidate(line)
        if ret is true or ret is false
          handleCommand()  if ret
        else
          commandResult ret, "jquery-console-message-error"
      else
        handleCommand()
      return

    # Scroll to the bottom of the view
    scrollToBottom = ->
      version = jQuery.fn.jquery.split(".")
      major = parseInt(version[0])
      minor = parseInt(version[1])

      # check if we're using jquery > 1.6
      if (major is 1 and minor > 6) or major > 1
        inner.prop scrollTop: inner.prop("scrollHeight")
      else
        inner.attr scrollTop: inner.attr("scrollHeight")
      return
    cancelExecution = ->
      config.cancelHandle()  if typeof config.cancelHandle is "function"
      return

    # Handle a command
    handleCommand = ->
      if typeof config.commandHandle is "function"
        disableInput()
        addToHistory promptText
        text = promptText
        if extern.continuedPrompt
          if continuedText
            continuedText += "\n" + promptText
          else
            continuedText = promptText
        else
          continuedText = `undefined`
        text = continuedText  if continuedText
        ret = config.commandHandle(text, (msgs) ->
          commandResult msgs
          return
        )
        continuedText = promptText  if extern.continuedPrompt and not continuedText
        if typeof ret is "boolean"
          if ret
            # Command succeeded without a result.
            commandResult()
          else
            commandResult "Command failed.", "jquery-console-message-error"
        else if typeof ret is "string"
          commandResult ret, "jquery-console-message-success"
        else if typeof ret is "object" and ret.length
          commandResult ret
        else commandResult()  if extern.continuedPrompt
      return

    # Disable input
    disableInput = ->
      acceptInput = false
      return

    # Enable input
    enableInput = ->
      acceptInput = true
      return

    # Reset the prompt in invalid command
    commandResult = (msg, className) ->
      column = -1
      updatePromptDisplay()
      if typeof msg is "string"
        message msg, className
      else if $.isArray(msg)
        for x of msg
          ret = msg[x]
          message ret.msg, ret.className
      else # Assume it's a DOM node or jQuery object.
        inner.append msg
      newPromptBox()
      return

    # Report some message into the console
    report = (msg, className) ->
      text = promptText
      promptBox.remove()
      commandResult msg, className
      extern.promptText text
      return

    # Display a message
    message = (msg, className) ->
      mesg = $("<div class=\"jquery-console-message\"></div>")
      mesg.addClass className  if className
      mesg.filledText(msg).hide()
      inner.append mesg
      mesg.show()
      return

    #//////////////////////////////////////////////////////////////////////
    # Handle normal character insertion
    # data can either be a number, which will be interpreted as the
    # numeric value of a single character, or a string

    # TODO: remove redundant indirection

    #//////////////////////////////////////////////////////////////////////
    # Move to another column relative to this one
    # Negative means go back, positive means go forward.

    moveColumn = (n) ->
      if column + n >= 0 and column + n <= promptText.length
        column += n
        true
      else
        false
    moveForward = ->
      if moveColumn(1)
        updatePromptDisplay()
        return true
      false
    moveBackward = ->
      if moveColumn(-1)
        updatePromptDisplay()
        return true
      false
    moveToStart = ->
      updatePromptDisplay()  if moveColumn(-column)
      return
    moveToEnd = ->
      updatePromptDisplay()  if moveColumn(promptText.length - column)
      return
    moveToNextWord = ->
      continue  while column < promptText.length and not isCharAlphanumeric(promptText[column]) and moveForward()
      continue  while column < promptText.length and isCharAlphanumeric(promptText[column]) and moveForward()
      return
    moveToPreviousWord = ->
      # Move backward until we find the first alphanumeric
      continue  while column - 1 >= 0 and not isCharAlphanumeric(promptText[column - 1]) and moveBackward()
      # Move until we find the first non-alphanumeric
      continue  while column - 1 >= 0 and isCharAlphanumeric(promptText[column - 1]) and moveBackward()
      return
    isCharAlphanumeric = (charToTest) ->
      if typeof charToTest is "string"
        code = charToTest.charCodeAt()
        return (code >= "A".charCodeAt() and code <= "Z".charCodeAt()) or (code >= "a".charCodeAt() and code <= "z".charCodeAt()) or (code >= "0".charCodeAt() and code <= "9".charCodeAt())
      false
    doComplete = ->
      if typeof config.completeHandle is "function"
        completions = config.completeHandle(promptText)
        len = completions.length
        if len is 1
          extern.promptText promptText + completions[0]
        else if len > 1 and config.cols
          prompt = promptText
          # Compute the number of rows that will fit in the width
          max = 0
          i = 0

          while i < len
            max = Math.max(max, completions[i].length)
            i++
          max += 2
          n = Math.floor(config.cols / max)
          buffer = ""
          col = 0
          i = 0
          while i < len
            completion = completions[i]
            buffer += completions[i]
            j = completion.length

            while j < max
              buffer += " "
              j++
            if ++col >= n
              buffer += "\n"
              col = 0
            i++
          commandResult buffer, "jquery-console-message-value"
          extern.promptText prompt
      return
    doNothing = ->

    # Update the prompt display
    updatePromptDisplay = ->
      line = promptText
      html = ""
      if column > 0 and line is ""
        # When we have an empty line just display a cursor.
        html = cursor
      else if column is promptText.length
        # We're at the end of the line, so we need to display
        # the text *and* cursor.
        html = htmlEncode(line) + cursor
      else
        # Grab the current character, if there is one, and
        # make it the current cursor.
        before = line.substring(0, column)
        current = line.substring(column, column + 1)
        current = "<span class=\"jquery-console-cursor\">" + htmlEncode(current) + "</span>"  if current
        after = line.substring(column + 1)
        html = htmlEncode(before) + current + htmlEncode(after)
      prompt.html html
      scrollToBottom()
      return

    # Simple HTML encoding
    # Simply replace '<', '>' and '&'
    # TODO: Use jQuery's .html() trick, or grab a proper, fast
    # HTML encoder.
    htmlEncode = (text) ->
      text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/</g, "&lt;").replace(RegExp(" ", "g"), "&nbsp;").replace /\n/g, "<br />"

    keyCodes =
      37: moveBackward()
      39: moveForward()
      38: previousHistory()
      40: nextHistory()
      8:  backDelete()
      46: forwardDelete()
      35: moveToEnd()
      36: moveToStart()
      13: commandTrigger()
      18: doNothing()
      9:  doComplete()

    ctrlCodes =
      65: moveToStart()
      69: moveToEnd()
      68: forwardDelete()
      78: nextHistory()
      80: previousHistory()
      66: moveBackward()
      70: moveForward()
      75: deleteUntilEnd()

    $.extend ctrlCodes, config.ctrlCodes  if config.ctrlCodes
    altCodes =
      70: moveToNextWord()
      66: moveToPreviousWord()
      68: deleteNextWord()

    (->
      extern.promptLabel = (if config and config.promptLabel then config.promptLabel else "> ")
      container.append inner
      inner.append typer
      typer.css
        position: "absolute"
        top: 0
        left: "-9999px"

      message config.welcomeMessage, "jquery-console-welcome"  if config.welcomeMessage
      newPromptBox()
      if config.autofocus
        inner.addClass "jquery-console-focus"
        typer.focus()
        setTimeout (->
          inner.addClass "jquery-console-focus"
          typer.focus()
          return
        ), 100
      extern.inner = inner
      extern.typer = typer
      extern.scrollToBottom = scrollToBottom
      extern.report = report
      return
    )()
    extern.reset = ->
      welcome = (typeof config.welcomeMessage isnt "undefined")
      removeElements = ->
        inner.find("div").each ->
          unless welcome
            $(this).remove()
          else
            welcome = false
          return

        return

      if fadeOnReset
        inner.parent().fadeOut ->
          removeElements()
          newPromptBox()
          inner.parent().fadeIn focusConsole
          return

      else
        removeElements()
        newPromptBox()
        focusConsole()
      return

    focusConsole = ->
      inner.addClass "jquery-console-focus"
      typer.focus()
      return

    extern.focus = ->
      focusConsole()
      return

    extern.notice = (msg, style) ->
      n = $("<div class=\"notice\"></div>").append($("<div></div>").text(msg)).css(visibility: "hidden")
      container.append n
      focused = true
      if style is "fadeout"
        setTimeout (->
          n.fadeOut ->
            n.remove()
            return

          return
        ), 4000
      else if style is "prompt"
        a = $("<br/><div class=\"action\"><a href=\"javascript:\">OK</a><div class=\"clear\"></div></div>")
        n.append a
        focused = false
        a.click ->
          n.fadeOut ->
            n.remove()
            inner.css opacity: 1
            return

          return

      h = n.height()
      n.css(
        height: "0px"
        visibility: "visible"
      ).animate
        height: h + "px"
      , ->
        inner.css opacity: 0.5  unless focused
        return

      n.css "cursor", "default"
      n

    container.click ->
      return false  if window.getSelection().toString()
      inner.addClass "jquery-console-focus"
      inner.removeClass "jquery-console-nofocus"
      if isWebkit
        typer.focusWithoutScrolling()
      else
        typer.css("position", "fixed").focus()
      scrollToBottom()
      false

    typer.blur ->
      inner.removeClass "jquery-console-focus"
      inner.addClass "jquery-console-nofocus"
      return

    typer.bind "paste", (e) ->
      typer.val ""
      setTimeout (->
        typer.consoleInsert typer.val()
        typer.val ""
        return
      ), 0
      return

    typer.keydown (e) ->
      cancelKeyPress = 0
      keyCode = e.keyCode
      if e.ctrlKey and keyCode is 67
        cancelKeyPress = keyCode
        cancelExecution()
        return false
      if acceptInput
        if e.shiftKey and keyCode of shiftCodes
          cancelKeyPress = keyCode
          (shiftCodes[keyCode])()
          false
        else if e.altKey and keyCode of altCodes
          cancelKeyPress = keyCode
          (altCodes[keyCode])()
          false
        else if e.ctrlKey and keyCode of ctrlCodes
          cancelKeyPress = keyCode
          (ctrlCodes[keyCode])()
          false
        else if keyCode of keyCodes
          cancelKeyPress = keyCode
          (keyCodes[keyCode])()
          false

    typer.keypress (e) ->
      keyCode = e.keyCode or e.which
      return false  if isIgnorableKey(e)
      return true  if (e.ctrlKey or e.metaKey) and String.fromCharCode(keyCode).toLowerCase() is "v"
      if acceptInput and cancelKeyPress isnt keyCode and keyCode >= 32
        return false  if cancelKeyPress
        typer.consoleInsert keyCode  if typeof config.charInsertTrigger is "undefined" or (typeof config.charInsertTrigger is "function" and config.charInsertTrigger(keyCode, promptText))
      false  if isWebkit

    typer.consoleInsert = (data) ->
      text = (if (typeof data is "number") then String.fromCharCode(data) else data)
      before = promptText.substring(0, column)
      after = promptText.substring(column)
      promptText = before + text + after
      moveColumn text.length
      restoreText = promptText
      updatePromptDisplay()
      return

    extern.promptText = (text) ->
      if typeof text is "string"
        promptText = text
        column = promptText.length
        updatePromptDisplay()
      promptText

    extern

  # Simple utility for printing messages
  $.fn.filledText = (txt) ->
    $(this).text txt
    $(this).html $(this).html().replace(/\n/g, "<br/>")
    this

  # Alternative method for focus without scrolling
  $.fn.focusWithoutScrolling = ->
    x = window.scrollX
    y = window.scrollY
    $(this).focus()
    window.scrollTo x, y
    return

  return
) jQuery
