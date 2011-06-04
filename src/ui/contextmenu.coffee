(($) ->
  cleanup = ->
    $(".ui_contextmenu_menu").remove()

  $(document.documentElement)
    .bind "mousedown keydown contextmenu", (e) ->
      if e.type is "keydown" and e.which isnt 27
        return

      if (e.type is "mousedown" or e.type is "contextmenu") and
          $(e.target).is(".ui_contextmenu_menu, .ui_contextmenu_menu *")
        return

      cleanup()

  $(window).bind "blur", ->
    cleanup()

  $.contextmenu = (menu, x, y) ->
    cleanup()

    $(menu)
      .addClass("ui_contextmenu_menu")
      .css(position: "fixed", left: x, top: y)
      .each ->
        $this = $(this)
        this_pos = $this.position()

        if window.innerWidth < this_pos.left + $this.outerWidth()
          $this.css(left: "", right: "0")

        if window.innerHeight < this_pos.top + $this.outerHeight()
          $this.css("top", "#{this_pos.top - $this.outerHeight()}px")

)(jQuery)