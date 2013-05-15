(function(document, window, undefined) {
  var times_to_change = $("header > small[data-timestamp]");

  $.each(times_to_change, function (idx, el) {
    el.innerHTML = el.innerHTML.replace('{{timestamp}}', moment.unix(el.getAttribute("data-timestamp")).fromNow());
  });
})(document, window);
