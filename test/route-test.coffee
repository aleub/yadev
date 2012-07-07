routes = require "../routes/"
should = require "should"

describe "feature", ->
  it "should add two numbers", ->
    (2+2).should.equal 4

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
  describe "index", ->
    it "should display index with posts", (done)->
      res =
        render: (view, vars) ->
          view.should.equal "index"
          vars.title.should.equal "yadev - yet another dev blog"
          done()
      routes.index(req, res)

describe "new post", ->
  it "should display the add post page", (done)->
    res.render = (view, vars) ->
      view.should.equal "add_post"
      vars.title.should.equal "Write New Post"
      done()
    routes.newPost req, res
