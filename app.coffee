express = require("express")
routes = require("./routes")
{settings} = require('./settings')
MongoStore = require("connect-mongo")(express)

#db = require("mongoskin").db 'localhost:27017/yadev'

gzippo = require("gzippo")
routes_admin = require("./admin/routes")

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


app.get "/", routes.index
app.get "/:post_title", routes.viewPost
app.get "/post/new", routes.newPost
app.get "/post/edit/:id", routes.editPost
app.get "/post/:id", routes.viewPost

app.post "/post/new", routes.addPost
app.post "/post/save", routes.addPost
app.post "/post/edit/:id", routes.savePost
app.post "/post/remove/:id", routes.removePost

app.listen settings.port_frontend || 3000, ->
  console.log "Yadev frontend listening on port %d in %s mode", app.address().port, app.settings.env


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
  app_admin.use gzippo.staticGzip(__dirname + '/admin/public')
  app_admin.use gzippo.compress()

app_admin.configure "development", ->
  app_admin.use express.errorHandler
    dumpExceptions: true
    showStack: true

app_admin.configure "production", ->
  app_admin.use express.errorHandler()

app_admin.get "/", routes_admin.login
app_admin.post "/login", routes_admin.auth
app_admin.get "/logout", routes_admin.logout

cs = (req, res, next) ->
  if req.session.user
    next()
  else
    res.redirect '/'

app_admin.get "/dashboard", cs, (req, res) ->
  routes_admin.dashboard(req, res)

app_admin.get "/articles", cs, (req, res) ->
  routes_admin.articles(req, res)

app_admin.get "/articles/new", cs, (req, res) ->
  routes_admin.articles_new(req, res)

app_admin.get "/articles/edit/:id", cs, (req, res) ->
  routes_admin.articles_edit(req, res)

app_admin.post "/articles/save/:id", cs, (req, res) ->
  routes_admin.articles_save(req, res)

app_admin.post "/articles/save", cs, (req, res) ->
  routes_admin.articles_save(req, res)

app_admin.get "/media", cs, (req, res) ->
  routes_admin.media(req, res)

app_admin.get "/pages", cs, (req, res) ->
  routes_admin.pages(req, res)

app_admin.get "/comments", cs, (req, res) ->
  routes_admin.comments(req, res)

app_admin.get "/settings", cs, (req, res) ->
  routes_admin.settings(req, res)


app_admin.listen settings.port_admin || 3001, ->
  console.log "Yadev admin listening on port %d in %s mode", app_admin.address().port, app_admin.settings.env
