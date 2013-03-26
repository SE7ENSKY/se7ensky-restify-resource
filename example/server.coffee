bunyan = require 'bunyan'
log = bunyan.createLogger
	name: APP_NAME
	level: 'debug'

restify = require 'restify'
server = restify.createServer
	name: 'example server'
	version: '1.1.4'
	log: log

server.use restify.requestLogger {}
server.use restify.acceptParser server.acceptable
server.use restify.queryParser()
server.use restify.jsonp()
# server.use restify.gzipResponse()
server.use restify.bodyParser { mapParams:no }

require('../index')(server, log, "#{__dirname}/resources")
server.resource 'items'

port = process.env.PORT or 3000
host = process.env.HOST or '0.0.0.0'
server.on 'listening', ->
	log.info { port:port, host:host }, "REST server started."
server.listen port, host