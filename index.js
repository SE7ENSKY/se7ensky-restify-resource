// Generated by CoffeeScript 1.4.0
var restify,
  __slice = [].slice;

restify = require('restify');

module.exports = function(server, log, resourcesPath) {
  var currentConfiguringControllerActions, currentConfiguringControllerName, currentConfiguringControllerPath, registerControllerMethod;
  if (resourcesPath == null) {
    resourcesPath = 'resources';
  }
  currentConfiguringControllerName = null;
  currentConfiguringControllerPath = null;
  currentConfiguringControllerActions = [];
  registerControllerMethod = function() {
    var args, fullUri, handler, handlers, relativeUri, verb, _i, _len;
    verb = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    if (typeof args[0] === 'string') {
      relativeUri = args[0];
      args.splice(0, 1);
    } else {
      relativeUri = '/';
    }
    handlers = args;
    for (_i = 0, _len = handlers.length; _i < _len; _i++) {
      handler = handlers[_i];
      if (typeof handler !== 'function') {
        log.error({
          controller: currentConfiguringControllerPath,
          verb: verb,
          relativeUri: relativeUri
        }, 'Resource misconfiguration: non-function handler passed');
      }
    }
    fullUri = "" + currentConfiguringControllerPath + "/" + relativeUri;
    currentConfiguringControllerActions.push("" + verb + " " + relativeUri);
    return server[verb](fullUri, function(req, res, next) {
      var context;
      context = {
        req: req,
        res: res,
        next: function(err) {
          if (err) {
            return next(err);
          } else {
            handler = handlers.shift();
            if (handler) {
              return handler.call(context);
            } else {
              return next();
            }
          }
        },
        respond: function(err, o) {
          if (err) {
            log.error(err, "Error handling request");
            return next(err);
          } else if (o) {
            log.info(o, "Successfully handled request");
            return res.send(o);
          } else {
            err = new restify.ResourceNotFoundError("Object not found");
            log.error(err);
            return next(err);
          }
        }
      };
      return context.next();
    });
  };
  global.GET = function(relativeUri, handler) {
    if (handler == null) {
      handler = null;
    }
    return registerControllerMethod('get', relativeUri, handler);
  };
  global.POST = function(relativeUri, handler) {
    if (handler == null) {
      handler = null;
    }
    return registerControllerMethod('post', relativeUri, handler);
  };
  global.HEAD = function(relativeUri, handler) {
    if (handler == null) {
      handler = null;
    }
    return registerControllerMethod('head', relativeUri, handler);
  };
  global.PUT = function(relativeUri, handler) {
    if (handler == null) {
      handler = null;
    }
    return registerControllerMethod('put', relativeUri, handler);
  };
  global.DELETE = function(relativeUri, handler) {
    if (handler == null) {
      handler = null;
    }
    return registerControllerMethod('del', relativeUri, handler);
  };
  return server.resource = function(name, path) {
    if (path == null) {
      path = null;
    }
    if (path === null) {
      path = "/" + name;
    }
    currentConfiguringControllerName = name;
    currentConfiguringControllerPath = path;
    log.info({
      controller: name,
      path: path
    }, "Configuring controller");
    require("" + resourcesPath + "/" + name);
    log.info({
      controller: name,
      path: path,
      actions: currentConfiguringControllerActions
    }, "Controller configured successfully");
    currentConfiguringControllerName = null;
    currentConfiguringControllerPath = null;
    return currentConfiguringControllerActions = [];
  };
};
