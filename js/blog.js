(function(document, window, undefined) {
  var times_to_change = $("header > small[data-timestamp]");

  $.each(times_to_change, function (idx, el) {
    el.innerHTML = el.innerHTML.replace('{{timestamp}}', moment(el.getAttribute("data-timestamp")).subtract('hours', 8).fromNow());
  });
})(document, window);
