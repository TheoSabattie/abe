package restx;

import express.Next;
import express.Request;
import express.Response;
import js.Error;
import restx.core.ArgumentProcessor;

class RouteProcess<TRoute : IRoute, TArgs : {}> {
  var instance : IRoute;
  var argumentProcessor : ArgumentProcessor<TArgs>;
  var arguments : TArgs;
  public function new(instance : IRoute, argumentProcessor : ArgumentProcessor<TArgs>) {
    this.instance = instance;
    this.argumentProcessor = argumentProcessor;
  }

  public function run(req : Request, res : Response, next : Next) {
    argumentProcessor.processArguments(req, arguments).then(function(result) {
      switch result {
        case Ok:
          instance.request = req;
          instance.response = res;
          instance.next = next;
          execute();
        case Required(param):
          // TODO add proper status code
          (next : Error -> Void)(new Error('Parameter "$param" is required'));
        case InvalidFilter(err):
          // TODO add proper status code
          (next : Error -> Void)(err);
      }
    });

  }

  function execute()
    throw 'RouteProcess.execute() must be overwritten';
}