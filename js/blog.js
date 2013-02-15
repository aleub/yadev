(function(document, window, undefined) {
  var _gaq = _gaq || [],
      app = {};

  _gaq.push(['_setAccount', 'UA-38500704-1']);
  _gaq.push(['_setDomainName', 'yadev.org']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'),
        s;
    ga.type = 'text/javascript';
    ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();
  
  var scrollTo = function (ele) {
    $('html, body').animate({
      scrollTop: $(ele).offset().top
    }, 400);
    //$('html, body').scrollTop($(ele).offset().top);
  };

  app.about = function () {
    scrollTo($(".page_about"));
  };

  app.projects = function () {
    scrollTo($(".page_projects"));
  };

  app.contact = function () {
    scrollTo($(".page_contact"));
  };

  app.home = function () {
    $("html").scrollTop(0);
  };
  
  app.article = function (article) {
    console.log("article name: " + article);
  };

  routie({
    'about': app.about,
    'projects': app.projects,
    'contact': app.contact,
    'article/:article_name': app.article,
    '*': app.home,
  });

  $(".content").each( function(el) {
    var $this = $(this),
        position = $this.position();

    $this.scrollspy({
      min: position.top -250,
      max: position.top + $this.height(),
      onEnter: function(ele, pos) {
        $('nav ul li a[href="' + $(ele).data('href') + '"]').css("font-weight", "bold");
        //console.log("enter");
      },
      onLeave: function(ele, pos) {
        $('nav ul li a[href="' + $(ele).data('href') + '"]').css("font-weight", "400");
      }
    });
  });

})(document, window);
