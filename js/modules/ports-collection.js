// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define('ports-collection', ['ProtoCollection', 'port'], function(ProtoCollection, port) {
    var PortsCollection, _ref;

    PortsCollection = (function(_super) {
      __extends(PortsCollection, _super);

      function PortsCollection() {
        _ref = PortsCollection.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PortsCollection.prototype.model = port;

      PortsCollection.prototype.containPath = function(id) {
        var isPath;

        isPath = false;
        this.each(function(port) {
          var connection, _i, _len, _ref1, _results;

          _ref1 = port.get('connections');
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            connection = _ref1[_i];
            console.log(connection);
            if (connection.path.get('id') === id) {
              _results.push(isPath = true);
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        });
        return isPath;
      };

      return PortsCollection;

    })(ProtoCollection);
    return PortsCollection;
  });

}).call(this);
