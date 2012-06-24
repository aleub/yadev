$("document").ready ->
  console.log("doc ready")

  $('a.remove-post').on 'click', (el) ->
    $this = $ this
    $.post '/post/remove/' + (($ this).data 'm-id'), (res) ->
      $this.parents('article').animate {opacity: 0}, 250, ->
        ($ @).remove()


  if window.matchMedia
    mq = window.matchMedia('(max-width: 767px)')
    mq.addListener (meq) ->
      $('.nav-admin > ul.nav')
        .removeClass("nav-list nav-pills")
        .addClass(if meq.matches then "nav-pills" else "nav-list")

    $('.nav-admin > ul.nav')
      .removeClass("nav-list nav-pills")
      .addClass(if mq.matches then "nav-pills" else "nav-list")



