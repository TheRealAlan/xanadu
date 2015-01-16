class Console

  constructor: ->

    # Selectors
    @$dialog      = $('.dialog')
    @$console     = $('.console')
    @$inner       = $('.console-inner')
    @$capture     = $('.console-capture')
    @$prompt      = $('.console-prompt')
    @$cursor      = $('.console-cursor')

    # Variables
    @pos          = 0
    @prompt_text  = ''
    @restore_text = ''
    @cursor       = @$cursor.html()

    # init
    @init()

  init: ->
    @_console_focus()
    @_document_click()
    @_capture_type();

  _document_click: ->
    $(document).on 'click', (ev) =>
      @_console_focus()

  _capture_type: ->
    @$capture.on 'keypress', (ev) =>

      if document.selection
        range = document.selection.createRange()
        range.moveStart('character', -@$capture[0].value.length)
        @pos = range.text.length
      else if @$capture[0].selectionStart or @$capture[0].selectionStart is '0'
        @pos = @$capture[0].selectionStart

      @_update_prompt()

      # console.log ev.keyCode
      keycode = ev.keyCode

      switch keycode
        # left
        when 37 then @_move_backward()
        # right
        when 39 then @_move_forward()
        # up
        when 38 then @_prev_history()
        # down
        when 40 then @_next_history()
        # backspace
        when 8 then @_backspace()
        # delete
        when 46 then @_forward_delete()
        # end
        when 35 then @_move_to_end()
        # start
        when 36 then @_move_to_start()
        # return
        when 13 then @_trigger_command()
        # tab
        when 18 then @_do_nothing()
        # tab
        when 0 then @_do_complete()

      # switch ctrlcode
      #   # C-a
      #   when 65 then @_move_to_start
      #   # C-e
      #   when 69 then @_move_to_end
      #   # C-d
      #   when 68 then @_forward_delete
      #   # C-n
      #   when 78 then @_next_distory
      #   # C-p
      #   when 80 then @_prev_history
      #   # C-b
      #   when 66 then @_move_backward
      #   # C-f
      #   when 70 then @_move_forward
      #   # C-k
      #   when 75 then @_delete_until_end
      #   else return false

      # switch altcode
      #   # M-f
      #   when 70 then @_move_to_next_word
      #   # M-b
      #   when 66 then @_move_to_previous_word
      #   # M-d
      #   when 68 then @_delete_next_word

      # switch shiftcode
      #   # return
      #   when 13 then @_new_line

  _console_focus: ->
    @$inner.addClass 'focused'
    @$capture.focus()

  _update_prompt: ->
    text = @$capture.val()
    html = ''
    console.log @pos

    if @pos > 0 and text is ''
      html = @cursor
    else if @pos is text.length
      html = @_html_encode text + @cursor4
    else
      before  = text.substring(0, @pos)
      current = text.substring(@pos, @pos + 1)
      after   = text.substring(@pos + 1)

      if current
        current = "<span class='console-cursor'>#{@_html_encode( current )}</span>"

      html = @_html_encode( before ) + current + @_html_encode( after )

    @$prompt.html( html )

  _insert_prompt: (data) ->
    text          = if typeof data is 'number' then String.fromCharCode( data ) else data
    before        = @prompt_text.substring(0, @pos)
    after         = @prompt_text.substring(@pos)
    @prompt_text  = before + text + after
    @_move_cursor(text.length)
    @restore_text = @prompt_text
    @_update_prompt()

  _html_encode: (text) ->
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/</g, '&lt;')
      .replace(RegExp(' ', 'g'), '&nbsp;')
      # .replace(/\n/g, '<br>')

  _move_forward: ->
    @_move_cursor( 1 )

  _move_backward: ->
    @_move_cursor( -1 )

  _move_cursor: (n) ->
    text = @$capture.val()

    if @pos + n >= 0 and @pos + n <= text.length
      @pos += n
      @_update_prompt()

  _scroll_to_bottom: ->
    @$console.velocity( 'scroll', {
      duration: 200
    })

  # _prev_history: ->
  #   @_update_prompt()

  # _next_history: ->
  #   @_update_prompt()

  # _backspace: ->
  #   @_update_prompt()

  # _forward_delete: ->
  #   @_update_prompt()

  # _delete_until_end: ->
  #   @_update_prompt()

  # _move_to_end: ->
  #   @_update_prompt()

  # _move_to_start: ->
  #   @_update_prompt()

  _trigger_command: ->
    input_text = @$prompt.text()

    if input_text
      input = "<div class='input'>#{input_text}</div>"
      @$dialog.append input
      @_clear_prompt()
      @_scroll_to_bottom()

  _clear_prompt: ->
    @$capture.val('')
    @$prompt.text('')
    @pos = 0

  # _new_line: ->
  #   @_update_prompt()

  # _do_nothing: ->
  #   @_update_prompt()

  # _do_complete: ->
  #   @_update_prompt()

$ ->

  window.Console = new Console