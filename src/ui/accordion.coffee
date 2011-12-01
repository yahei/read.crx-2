(($) ->
  $.fn.accordion = ->
    $this = $(this)
    refresh = $this.hasClass("accordion")
    $this
      .addClass("accordion")
      .find(".accordion_open")
        .removeClass("accordion_open")
      .end()
      .find(":header + :not(:header)")
        .hide()
      .end()
      .find("> :header:eq(0)")
        .addClass("accordion_open")
          .next()
            .show()

    if not refresh
      $this
        .delegate ".accordion > :header", "click", ->
          $(this)
            .toggleClass("accordion_open")
            .next()
              .stop(true, true)
              .slideToggle(250)
            .end()
            .siblings(".accordion_open")
              .removeClass("accordion_open")
              .next()
                .stop(true, true)
                .slideUp(250)
          return
    this
)(jQuery)
