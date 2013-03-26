restify = require 'restify'

module.exports = (server, log, resourcesPath = 'resources') ->
	currentConfiguringControllerName = null
	currentConfiguringControllerPath = null
	currentConfiguringControllerActions = []
	registerControllerMethod = (verb, args) ->
		relativeUri = if typeof args[0] is 'string' then args.shift() else ''

		for handler in args
			if typeof handler isnt 'function'
				log.error
					controller: currentConfiguringControllerPath
					verb: verb
					relativeUri: relativeUri
				, 'Resource misconfiguration: non-function handler passed'

		fullUri = "#{currentConfiguringControllerPath}/#{relativeUri}"
		currentConfiguringControllerActions.push "#{verb} #{fullUri}"
		server[verb] fullUri, (req, res, next) ->
			handlers = args.slice()
			req.log.debug { req: req }, "Received request"
			req.context = res.context =
				req: req
				res: res
				next: (err) ->
					if err
						req.log.error { err: err }, "Error handling request"
						next err
					else
						handler = handlers.shift()
						if handler
							callNext = handlers.length is 0
							handler.call req.context
							req.context.next() if callNext
						else
							req.log.debug { res: res }, "Request handled"
							next()
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
			req.context.next()

	global.GET = (args...) -> registerControllerMethod 'get', args
	global.POST = (args...) -> registerControllerMethod 'post', args
	global.HEAD = (args...) -> registerControllerMethod 'head', args
	global.PUT = (args...) -> registerControllerMethod 'put', args
	global.DELETE = (args...) -> registerControllerMethod 'del', args

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