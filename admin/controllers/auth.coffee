{settings} = require('../../settings')

module.exports.routes =
  login: (req, res) ->
    res.render 'login',
      actions: {}
      layout: 'layout_clean'

  logout: (req, res) ->
    req.session.destroy()
    res.redirect '/'

  auth: (req, res) ->
    if req.body.post.username != settings.user_admin or req.body.post.password != settings.pwd_admin
      delete req.session.user
      res.render 'login',
        layout: 'layout_clean'
        actions: {
          error: "  no way!"
        }
    else
      req.session.user = req.body.post.username
      res.redirect '/dashboard'
