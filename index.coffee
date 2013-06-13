restify = require 'restify'

mongoose = require 'mongoose'
util = require 'util'

RestMongooseValidationError = (mongooseValidationError) ->
	restify.RestError.call @,
		restCode: 'ValidationError'
		statusCode: 409
		message: mongooseValidationError.message
		constructorOpt: RestMongooseValidationError
		body:
			code: 'ValidationError'
			message: mongooseValidationError.message
			errors: mongooseValidationError.errors
	@name = 'RestMongooseValidationError'

util.inherits RestMongooseValidationError, restify.RestError

explodeMiddlewares = (input) ->
	if input instanceof Array
		result = []
		for item in input
			result = result.concat explodeMiddlewares item
		result
	else
		[ input ]

module.exports = (server, log, resourcesPath = 'resources') ->
	currentConfiguringControllerName = null
	currentConfiguringControllerPath = null
	currentConfiguringControllerActions = []

	registerControllerMethod = (verb, args) ->
		relativeUri = if typeof args[0] is 'string' then args.shift() else ''

		args = explodeMiddlewares args
		for handler in args
			if typeof handler isnt 'function'
				log.error
					controller: currentConfiguringControllerPath
					verb: verb
					relativeUri: relativeUri
				, 'Resource misconfiguration: non-function handler passed'

		fullUri = "#{currentConfiguringControllerPath}/#{relativeUri}"
		currentConfiguringControllerActions.push "#{verb} #{fullUri}"
		server[verb] fullUri, (req, res, globalNext) ->
			handlers = args.slice()
			req.log.debug { req: req }, "Received request"
			req.context = res.context =
				req: req
				res: res
				log: req.log
				globalNext: globalNext
				next: (err) ->
					if err
						req.log.error { err: err }, "Error handling request"
						globalNext err
					else
						handler = handlers.shift()
						if handler
							handler.call req.context, req, res, req.context.next
						else
							req.log.debug { res: res }, "Request handled"
							globalNext()
				respond: (err, o = null) ->
					if o is null and typeof err is 'string'
						o = err
						err = null

					if err
						if err instanceof mongoose.Error.ValidationError
							req.context.next new RestMongooseValidationError err
						else
							req.context.next err
					else if o
						req.log.info { object: o }, "Responding with object"
						res.send o
					else
						err = new restify.ResourceNotFoundError "Object not found"
						req.context.next err
			req.context.next()

	global.GET = (args...) -> registerControllerMethod 'get', args
	global.POST = (args...) -> registerControllerMethod 'post', args
	global.HEAD = (args...) -> registerControllerMethod 'head', args
	global.PUT = (args...) -> registerControllerMethod 'put', args
	global.DELETE = (args...) -> registerControllerMethod 'del', args
	global.OPTIONS = (args...) -> registerControllerMethod 'opts', args

	server.resource = (name, path = null) ->
		path = "/#{name}" if path is null
		currentConfiguringControllerName = name
		currentConfiguringControllerPath = path
		log.info { controller:name, path:path }, "Configuring controller"
		require "#{resourcesPath}/#{name}"
		log.info { controller:name, path:path, actions:currentConfiguringControllerActions }, "Controller configured successfully"
		currentConfiguringControllerName = null
		currentConfiguringControllerPath = null
		currentConfiguringControllerActions = []
