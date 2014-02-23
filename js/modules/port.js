// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define('port', ['ProtoClass', 'path', 'helpers', 'hammer'], function(ProtoClass, Path, helpers, hammer) {
    var Port, _ref;
    Port = (function(_super) {
      __extends(Port, _super);

      function Port() {
        _ref = Port.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Port.prototype.defaults = {
        size: 1,
        type: 'port'
      };

      Port.prototype.initialize = function(o) {
        this.o = o != null ? o : {};
        this.path = null;
        this.o.parent && (this.set('parent', this.o.parent));
        this.set({
          'connections': []
        });
        this.set('coords', this.o.coords);
        this.setIJ();
        this.addConnection(this.o.path);
        this.render();
        this.events();
        this.on('change:ij', _.bind(this.onChange, this));
        return this;
      };

      Port.prototype.events = function() {
        var _this = this;
        hammer(this.el).on('drag', function(e) {
          var coords;
          coords = App.grid.normalizeCoords(helpers.getEventCoords(e));
          App.currPath = _this.path;
          _this.set('ij', coords);
          e.preventDefault();
          return e.stopPropagation();
        });
        return hammer(this.el).on('release', function(e) {
          var coords;
          switch (_this.get('type')) {
            case 'event':
              coords = App.currBlock.getNearestPort(App.currBlock.placeCurrentEvent(e));
              break;
            case 'port':
              coords = App.currBlock.getNearestPort(App.grid.normalizeCoords(helpers.getEventCoords(e)));
          }
          _this.set({
            'coords': coords,
            'parent': App.currBlock
          });
          _this.setIJ();
          App.currPath = null;
          e.preventDefault();
          return e.stopPropagation();
        });
      };

      Port.prototype.onChange = function() {
        var connection;
        connection = this.get('connection');
        connection.path.set("" + connection.direction + "IJ", this.get('ij'));
        App.grid.refreshGrid();
        return this.render();
      };

      Port.prototype.render = function() {
        var ij, size;
        if (this.el == null) {
          this.el = this.createDomElement();
        }
        ij = this.get('ij');
        size = this.get('size');
        size = size * App.gs;
        this.addition = this.normalizeArrowCoords();
        return App.SVG.setAttributes(this.el, {
          transform: "translate(" + ((ij.i * App.gs) + this.addition.x) + "," + ((ij.j * App.gs) + this.addition.y) + ") rotate(" + this.addition.angle + "," + (size / 2) + "," + (size / 2) + ")"
        });
      };

      Port.prototype.normalizeArrowCoords = function() {
        var angle, coords, x, y;
        coords = this.get('coords');
        angle = 0;
        x = 0;
        y = 0;
        if (this.get('connection').direction === 'end') {
          if (coords.dir === 'i') {
            if (coords.side === 'startIJ') {
              angle = -90;
              x = (App.gs / 2) + 2;
            } else {
              angle = 90;
              x = -(App.gs / 2) - 2;
            }
          } else {
            if (coords.side === 'startIJ') {
              y = (App.gs / 2) + 2;
            } else {
              angle = 180;
              y = -(App.gs / 2) - 2;
            }
          }
        }
        return {
          angle: angle,
          x: x,
          y: y
        };
      };

      Port.prototype.createDomElement = function() {
        var attrs, connection, el, size;
        connection = this.get('connection');
        size = this.get('size');
        if (connection.direction === 'start') {
          attrs = {
            width: size * App.gs,
            height: size * App.gs,
            "class": 'port',
            rx: App.gs / 2
          };
          el = App.SVG.createElement('rect', attrs);
          App.SVG.lineToDom(el);
        } else {
          size = size * App.gs;
          attrs = {
            width: size,
            height: size,
            "class": 'port-arrow',
            points: "3,0 " + (size - 3) + ",0 " + (size / 2) + "," + (size - 10)
          };
          el = App.SVG.createElement('polygon', attrs);
          App.SVG.lineToDom(el);
        }
        return el;
      };

      Port.prototype.removeFromDom = function() {
        return App.SVG.removeElem(this.el);
      };

      Port.prototype.addConnection = function(path) {
        var direction, point;
        direction = '';
        if (path == null) {
          path = new Path;
          path.set({
            'connectedStart': this.get('parent'),
            'startIJ': this.get('ij'),
            'endIJ': this.get('ij')
          });
          direction = 'start';
          path.set('from', this);
        } else {
          point = path.currentAddPoint || 'endIJ';
          direction = point === 'startIJ' ? 'start' : 'end';
          if (point === 'startIJ') {
            path.set({
              'startIJ': this.get('ij'),
              'connectedStart': this.get('parent')
            });
            path.set('from', this);
          } else {
            path.set({
              'endIJ': this.get('ij'),
              'connectedEnd': this.get('parent')
            });
            path.set('in', this);
          }
        }
        this.set('connection', {
          direction: direction,
          path: path,
          id: App.helpers.genHash()
        });
        this.path = path;
        return path;
      };

      /*
      		 * [setIJ set relative coordinates from nearest port/event object]
      */


      Port.prototype.setIJ = function() {
        var coords, ij, parent, parentStartIJ, side;
        parent = this.get('parent');
        parentStartIJ = parent.get('startIJ');
        if (this.get('positionType') !== 'fixed') {
          ij = {
            i: parentStartIJ.i + ~~(parent.get('w') / 2),
            j: parentStartIJ.j + ~~(parent.get('h') / 2)
          };
        } else {
          coords = this.get('coords');
          side = parent.get(coords.side)[coords.dir] - (coords.side === 'startIJ' ? 1 : 0);
          ij = coords.dir === 'i' ? {
            i: side,
            j: parentStartIJ.j + coords.coord
          } : {
            i: parentStartIJ.i + coords.coord,
            j: side
          };
        }
        this.set('ij', ij);
        return this;
      };

      Port.prototype.destroy = function() {
        hammer(this.el).off('drag');
        this.removeFromDom();
        return Port.__super__.destroy.apply(this, arguments);
      };

      return Port;

    })(ProtoClass);
    return Port;
  });

}).call(this);
