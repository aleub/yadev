{settings} = require('../settings')

routes = require "../admin/routes/"
should = require "should"
sys = require 'sys'

describe "basic test setup", ->
  it "should have should", ->
    should.exist should
  it "has a set of core modules", ->
    should.exist require 'express'
    should.exist require 'fs'
    should.exist require 'events'
    should.exist require 'http'
    should.exist require('underscore')._

describe "routes", ->
  req = {}
  res = {}
  describe "compile", ->
    it "should return valid html", (done)->
      res.send = (value) ->
        value.html.should.equal "<h1>foobar</h1>"
        done()
      req.body =
        templating: 'markdown',
        src: "#foobar"

      routes.compile(req, res)
  describe "auth", ->
    it "shouldn't let anybody in", (done)->
      req.body = post :
        username: "anybody"
        password:  "empty"
      req.session = {}

      res.render = (view, data) ->
        view.should.equal "login"
        done()

      routes.auth(req, res)
    it "should let admin in ", (done)->
      req.body = post:
        username: settings.user_admin
        password: settings.pwd_admin
      req.session = {}

      res.redirect = (val) ->
        val.should.eql "/dashboard"
        req.session.user.should.eql settings.user_admin
        done()

      routes.auth(req, res)
    it "should logout cleanly", (done)->
      req.session = { alive: true}

      req.session.destroy = ->
        @.alive = false

      res.redirect = (val) ->
        val.should.eql "/"
        req.session.alive.should.not.be.ok
        done()

      routes.logout(req, res)
