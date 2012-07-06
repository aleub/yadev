// Generated by CoffeeScript 1.3.3
(function() {

  $("document").ready(function() {
    var $editor_element, editor, mq, preview;
    console.log("doc ready");
    preview = {
      render: function(val) {
        var obj;
        obj = $.extend({}, {
          templating: $("input[type='radio']:checked").val(),
          src: val
        });
        return $.post('/compile', obj, function(rc) {
          if (rc && rc.html) {
            console.log(rc.html);
            return $('.preview').html(rc.html);
          }
        });
      }
    };
    $editor_element = $('#ace-editor');
    if ($editor_element[0]) {
      editor = ace.edit('ace-editor');
      editor.getSession().setTabSize(2);
      $editor_element.closest('form').submit(function() {
        var code;
        code = editor.getValue();
        return $('#post').val(code);
      });
      editor.getSession().on('change', function() {
        return preview.render(editor.getSession().getValue());
      });
      preview.render(editor.getSession().getValue());
    }
    $("[rel='popover']").popover();
    $('a.remove-post').on('click', function(el) {
      var $this;
      $this = $(this);
      return $.post('/post/remove/' + (($(this)).data('m-id')), function(res) {
        return $this.parents('article').animate({
          opacity: 0
        }, 250, function() {
          return ($(this)).remove();
        });
      });
    });
    if (window.matchMedia) {
      mq = window.matchMedia('(max-width: 767px)');
      mq.addListener(function(meq) {
        return $('.nav-admin > ul.nav').removeClass("nav-list nav-pills").addClass(meq.matches ? "nav-pills" : "nav-list");
      });
      return $('.nav-admin > ul.nav').removeClass("nav-list nav-pills").addClass(mq.matches ? "nav-pills" : "nav-list");
    }
  });

}).call(this);
