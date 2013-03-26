restify = require 'restify'

module.exports = (server, log, resourcesPath = 'resources') ->
	currentConfiguringControllerName = null
	currentConfiguringControllerPath = null
	currentConfiguringControllerActions = []
	registerControllerMethod = (verb, args...) ->
		if typeof args[0] is 'string'
			relativeUri = args[0]
			args.splice 0, 1
		else
			relativeUri = '/'

		handlers = args
		for handler in handlers
			if typeof handler isnt 'function'
				log.error
					controller: currentConfiguringControllerPath
					verb: verb
					relativeUri: relativeUri
				, 'Resource misconfiguration: non-function handler passed'

		fullUri = "#{currentConfiguringControllerPath}/#{relativeUri}"
		currentConfiguringControllerActions.push "#{verb} #{relativeUri}"
		server[verb] fullUri, (req, res, next) ->
			nextHandler = null
			context =
				req: req
				res: res
				next: nextHandler
				respond: (err, o) ->
					if err
						log.error err, "Error handling request"
						next err
					else if o
						log.info o, "Successfully handled request"
						res.send o
					else
						err = new restify.ResourceNotFoundError "Object not found"
						log.error err
						next err
			nextHandler = (err) ->
				if err
					next err
				else
					handler = handlers.shift()
					if handler
						handler.call context
					else
						next()
			nextHandler()

	global.GET = (relativeUri, handler = null) -> registerControllerMethod 'get', relativeUri, handler
	global.POST = (relativeUri, handler = null) -> registerControllerMethod 'post', relativeUri, handler
	global.HEAD = (relativeUri, handler = null) -> registerControllerMethod 'head', relativeUri, handler
	global.PUT = (relativeUri, handler = null) -> registerControllerMethod 'put', relativeUri, handler
	global.DELETE = (relativeUri, handler = null) -> registerControllerMethod 'del', relativeUri, handler

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