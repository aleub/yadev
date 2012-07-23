express = require("express")
routes = require("./routes")
{settings} = require('./settings')
MongoStore = require("connect-mongo")(express)
cluster = require 'cluster'


#check mongo

app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

app.configure "production", ->
  app.use express.errorHandler()

log_route = (req, res, next) ->
  console.log req.route.path
  next()

app.get "/", log_route, routes.index
app.get "/res/combined.:type",log_route, routes.combineResources
app.get "/:post_title", log_route, routes.viewPost
app.get "/cat/:category", log_route, routes.viewCategory
app.get "/post/:id", log_route, routes.viewPost
app.post "/comment/:article_id", routes.addComment

app.listen settings.port_frontend || 3000, ->
  console.log "Yadev frontend listening on port %d in %s mode", app.address().port, app.settings.env

###
#ADMIN
###
routes_admin = require("./admin/routes")

app_admin = express.createServer()
app_admin.configure ->
  app_admin.set "views", __dirname + "/admin/views"
  app_admin.set "view engine", "jade"
  app_admin.use express.bodyParser()
  app_admin.use express.static(__dirname + "/admin/public")
  app_admin.use express.cookieParser()
  app_admin.use express.session(
    secret: "foobar"
    store: new MongoStore(db: 'yadev')
  )
  app_admin.use app_admin.router

app_admin.configure "development", ->
  app_admin.use express.errorHandler
    dumpExceptions: true
    showStack: true

app_admin.configure "production", -> app_admin.use express.errorHandler()

app_admin.get "/", routes_admin.login
app_admin.post "/login", routes_admin.auth
app_admin.get "/logout", routes_admin.logout

check_session = (req, res, next) ->
  console.log req.route.path
  if req.session.user
    next()
  else
    res.redirect '/'

app_admin.get "/dashboard", check_session, routes_admin.dashboard

app_admin.get  "/articles", check_session, routes_admin.articles
app_admin.get  "/articles/new", check_session, routes_admin.articles_new
app_admin.get  "/articles/edit/:id", check_session, routes_admin.articles_edit
app_admin.post "/articles/save/:id", check_session, routes_admin.articles_save
app_admin.post "/articles/save", check_session, routes_admin.articles_save
app_admin.post "/articles/remove", check_session, routes_admin.articles_remove

app_admin.post "/compile", check_session, routes_admin.compile

app_admin.get  "/media", check_session, routes_admin.media
app_admin.post  "/media/upload", check_session, routes_admin.upload
app_admin.get  "/pages", check_session, routes_admin.pages
app_admin.get  "/comments", check_session, routes_admin.comments

app_admin.get  "/settings", check_session, routes_admin.settings
app_admin.post  "/settings/save", check_session, routes_admin.settings_save

app_admin.listen settings.port_admin || 3001, ->
  console.log "Yadev admin listening on port %d in %s mode", app_admin.address().port, app_admin.settings.env
