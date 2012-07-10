$("document").ready ->
  console.log("doc ready")

  preview =
    render: (val) ->
      obj = $.extend({}, templating: $("input[type='radio']:checked").val(), src: val)
      $.post('/compile', obj, (rc) ->
        if rc && rc.html
          console.log rc.html
          $('.preview').html(rc.html)
      )

  $editor_element = $('#ace-editor')

  if $editor_element[0]
    editor = ace.edit 'ace-editor'

    editor.getSession().setTabSize(2)

    $editor_element.closest('form').submit( ->
      code = editor.getValue()
      $('#post').val(code)
    )

    editor.getSession().on('change', () ->
      preview.render(editor.getSession().getValue())
    )

    preview.render(editor.getSession().getValue())

  ##shiny stuff
  $("[rel='popover']").popover();

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
