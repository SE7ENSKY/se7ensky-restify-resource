restify = require 'restify'

module.exports = (server, log, resourcesPath = 'resources') ->
	currentConfiguringControllerName = null
	currentConfiguringControllerPath = null
	currentConfiguringControllerActions = []
	registerControllerMethod = (verb, relativeUri, handler = null) ->
		if handler is null
			handler = relativeUri
			relativeUri = '/'
		fullUri = "#{currentConfiguringControllerPath}/#{relativeUri}"
		currentConfiguringControllerActions.push "#{verb} #{relativeUri}"
		server[verb] fullUri, (req, res, next) ->
			handler.call
				req: req
				res: res
				next: next
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