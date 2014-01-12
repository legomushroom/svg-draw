// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define('block', ['backbone', 'underscore', 'helpers', 'ProtoClass', 'hammer', 'path', 'ports-collection', 'port'], function(B, _, helpers, ProtoClass, hammer, Path, PortsCollection, Port) {
    var Block, _ref;

    Block = (function(_super) {
      __extends(Block, _super);

      function Block() {
        _ref = Block.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Block.prototype.type = 'block';

      Block.prototype.defaults = {
        isValid: false,
        startIJ: {
          i: 0,
          j: 0
        },
        endIJ: {
          i: 0,
          j: 0
        },
        isDragMode: true,
        isValidPosition: true,
        isValidSize: false
      };

      Block.prototype.initialize = function(o) {
        var coords,
          _this = this;

        this.o = o != null ? o : {};
        this.set({
          'id': helpers.genHash()
        });
        if (this.o.coords) {
          coords = App.grid.normalizeCoords(App.grid.getNearestCell(this.o.coords || {
            x: 0,
            y: 0
          }));
          this.set({
            'startIJ': coords,
            'endIJ': coords
          });
        }
        this.ports = new PortsCollection;
        window.ports = this.ports;
        this.release = _.bind(this.release, this);
        this.ports.on('destroy', function() {
          return console.log('destroy');
        });
        this.render();
        this.on('change', _.bind(this.render, this));
        return this;
      };

      Block.prototype.createPort = function(o) {
        var port;

        o.parent = this;
        port = new Port(o);
        this.ports.add(port);
        console.log(this.ports);
        return port;
      };

      Block.prototype.render = function() {
        var startIJ;

        this.calcDimentions();
        if (this.$el == null) {
          this.$el = $('<div>').addClass('block-e').append($('<div>'));
          App.$main.append(this.$el);
          this.listenEvents();
        }
        startIJ = this.get('startIJ');
        this.$el.css({
          'width': this.get('w') * App.gs,
          'height': this.get('h') * App.gs,
          'top': startIJ.j * App.gs,
          'left': startIJ.i * App.gs
        }).toggleClass('is-invalid', !this.get('isValid') || (this.get('w') * App.gs < App.gs) || (this.get('h') * App.gs < App.gs));
        return this;
      };

      Block.prototype.calcDimentions = function() {
        var endIJ, startIJ;

        startIJ = this.get('startIJ');
        endIJ = this.get('endIJ');
        this.set({
          'w': endIJ.i - startIJ.i,
          'h': endIJ.j - startIJ.j
        });
        return this.refreshPort();
      };

      Block.prototype.listenEvents = function() {
        var _this = this;

        hammer(this.$el[0]).on('touch', function(e) {
          var coords, port;

          coords = App.grid.normalizeCoords(helpers.getEventCoords(e));
          if (App.currTool === 'path') {
            port = _this.createPort({
              coords: _this.getNearestPort(coords),
              positionType: 'fixed'
            });
            App.isBlockToPath = port.path;
          }
          return helpers.stopEvent(e);
        });
        hammer(this.$el[0]).on('drag', function(e) {
          var coords;

          if (App.blockDrag) {
            return true;
          }
          coords = helpers.getEventCoords(e);
          if (App.currTool === 'block') {
            _this.moveTo({
              x: e.gesture.deltaX,
              y: e.gesture.deltaY
            });
            helpers.stopEvent(e);
          }
          if (App.currTool === 'path') {
            return _this.highlightCurrPort(e);
          }
        });
        hammer(this.$el[0]).on('release', this.release);
        this.$el.on('mouseenter', function() {
          if (_this.isDragMode) {
            return;
          }
          App.currBlock = _this;
          if (App.currTool === 'path') {
            return _this.$el.addClass('is-connect-path');
          } else {
            return _this.$el.addClass('is-drag');
          }
        });
        return this.$el.on('mouseleave', function() {
          if (_this.isDragMode) {
            return;
          }
          App.currBlock = null;
          if (App.currTool === 'path') {
            return _this.$el.removeClass('is-connect-path');
          } else {
            return _this.$el.removeClass('is-drag');
          }
        });
      };

      Block.prototype.highlightCurrPort = function(e) {
        var coef, coords, i, j, node, portCoords, relativePortCoords;

        this.highlighted && App.grid.lowlightCell(this.highlighted);
        if (!App.currBlock) {
          return true;
        }
        coords = App.grid.normalizeCoords(helpers.getEventCoords(e));
        relativePortCoords = App.currBlock.getNearestPort(coords);
        coef = relativePortCoords.side === 'startIJ' ? -1 : 0;
        if (relativePortCoords.dir === 'j') {
          if (relativePortCoords.side === 'startIJ') {
            i = App.currBlock.get(relativePortCoords.side).i + relativePortCoords.coord;
            j = App.currBlock.get(relativePortCoords.side).j + coef;
          } else {
            i = App.currBlock.get('startIJ').i + relativePortCoords.coord;
            j = App.currBlock.get(relativePortCoords.side).j + coef;
          }
        } else {
          if (relativePortCoords.side === 'startIJ') {
            i = App.currBlock.get(relativePortCoords.side).i + coef;
            j = App.currBlock.get(relativePortCoords.side).j + relativePortCoords.coord;
          } else {
            i = App.currBlock.get(relativePortCoords.side).i + coef;
            j = App.currBlock.get('startIJ').j + relativePortCoords.coord;
          }
        }
        portCoords = {
          i: i,
          j: j
        };
        node = App.grid.grid.getNodeAt(i, j);
        App.grid.highlightCell(portCoords);
        return this.highlighted = portCoords;
      };

      Block.prototype.release = function(e) {
        var coords, coordsIJ, port, _ref1, _ref2;

        coords = helpers.getEventCoords(e);
        coordsIJ = App.grid.normalizeCoords(coords);
        if (App.currTool === 'path') {
          if (App.currPath && App.currBlock) {
            if (App.currPath.get('from') || App.currPath.get('in')) {
              if (this.ports.containPath(App.currPath.get('id'))) {
                console.log('yes');
              }
              if (App.currPath.currentAddPoint === 'startIJ') {
                if ((_ref1 = App.currPath.get('from')) != null) {
                  _ref1.destroy();
                }
              } else {
                if ((_ref2 = App.currPath.get('in')) != null) {
                  _ref2.destroy();
                }
              }
            }
            port = App.currBlock.createPort({
              path: App.currPath,
              coords: App.currBlock.getNearestPort(coordsIJ),
              positionType: 'fixed'
            });
            App.currPath.currentAddPoint = null;
            App.isBlockToPath = null;
          }
        } else {
          this.addFinilize();
          return false;
        }
        return helpers.stopEvent(e);
      };

      Block.prototype.getNearestPort = function(ij) {
        var coord, dir, endIJ, i, j, portCoords, side, startIJ;

        startIJ = this.get('startIJ');
        endIJ = this.get('endIJ');
        i = (startIJ.i + this.get('w') / 2) - ij.i - 1;
        j = (startIJ.j + this.get('h') / 2) - ij.j - 1;
        if (Math.abs(i) >= Math.abs(j)) {
          dir = 'i';
          side = i < 0 ? 'endIJ' : 'startIJ';
          coord = ij.j - startIJ.j;
        } else {
          dir = 'j';
          side = j < 0 ? 'endIJ' : 'startIJ';
          coord = ij.i - startIJ.i;
        }
        return portCoords = {
          dir: dir,
          side: side,
          coord: coord
        };
      };

      Block.prototype.moveTo = function(coords) {
        var bottom, left, right, shift, top;

        this.removeSelfFromGrid();
        coords = App.grid.normalizeCoords(coords);
        if (!this.isMoveTo) {
          this.buffStartIJ = helpers.cloneObj(this.get('startIJ'));
          this.buffEndIJ = helpers.cloneObj(this.get('endIJ'));
          this.isMoveTo = true;
        }
        top = this.buffStartIJ.j + coords.j;
        bottom = this.buffEndIJ.j + coords.j;
        left = this.buffStartIJ.i + coords.i;
        right = this.buffEndIJ.i + coords.i;
        if (top < 0) {
          shift = top;
          top = 0;
          bottom = top + this.get('h');
        }
        if (left < 0) {
          shift = left;
          left = 0;
          right = left + this.get('w');
        }
        this.setToGrid({
          i: left,
          j: top
        }, {
          i: right,
          j: bottom
        });
        return this.set({
          'startIJ': {
            i: left,
            j: top
          },
          'endIJ': {
            i: right,
            j: bottom
          },
          'isValid': this.isSuiteSize()
        });
      };

      Block.prototype.setSizeDelta = function(deltas) {
        var startIJ;

        startIJ = this.get('startIJ');
        return this.set({
          'endIJ': {
            i: startIJ.i + deltas.i,
            j: startIJ.j + deltas.j
          },
          'isValid': this.isSuiteSize()
        });
      };

      Block.prototype.isSuiteSize = function() {
        var endIJ, i, isValidSize, j, node, startIJ, _i, _j, _ref1, _ref2, _ref3, _ref4;

        startIJ = this.get('startIJ');
        endIJ = this.get('endIJ');
        this.isValidPosition = true;
        for (i = _i = _ref1 = startIJ.i, _ref2 = endIJ.i; _ref1 <= _ref2 ? _i < _ref2 : _i > _ref2; i = _ref1 <= _ref2 ? ++_i : --_i) {
          for (j = _j = _ref3 = startIJ.j, _ref4 = endIJ.j; _ref3 <= _ref4 ? _j < _ref4 : _j > _ref4; j = _ref3 <= _ref4 ? ++_j : --_j) {
            node = App.grid.grid.getNodeAt(i, j);
            if ((node.block != null) && (node.block.get('id') !== this.get('id'))) {
              this.set('isValidPosition', false);
              return false;
            }
          }
        }
        this.calcDimentions();
        isValidSize = this.get('w') > 0 && this.get('h') > 0;
        this.set({
          'isValidSize': isValidSize,
          'isValidPosition': true
        });
        return isValidSize;
      };

      Block.prototype.addFinilize = function() {
        this.isMoveTo = false;
        if (!this.get('isValid') && !this.get('isValidSize')) {
          this.removeSelf();
          return false;
        } else if (!this.get('isValidPosition')) {
          this.set({
            'startIJ': helpers.cloneObj(this.buffStartIJ),
            'endIJ': helpers.cloneObj(this.buffEndIJ),
            'isValid': true,
            'isValidPosition': true
          });
        }
        this.isDragMode = false;
        return this.setToGrid();
      };

      Block.prototype.refreshPort = function() {
        var _this = this;

        return this.ports.each(function(port) {
          return port.setIJ();
        });
      };

      Block.prototype.setToGrid = function(startIJ, endIJ) {
        var i, j, _i, _j, _ref1, _ref2, _ref3, _ref4;

        if (startIJ == null) {
          startIJ = this.get('startIJ');
        }
        if (endIJ == null) {
          endIJ = this.get('endIJ');
        }
        for (i = _i = _ref1 = startIJ.i, _ref2 = endIJ.i; _ref1 <= _ref2 ? _i < _ref2 : _i > _ref2; i = _ref1 <= _ref2 ? ++_i : --_i) {
          for (j = _j = _ref3 = startIJ.j, _ref4 = endIJ.j; _ref3 <= _ref4 ? _j < _ref4 : _j > _ref4; j = _ref3 <= _ref4 ? ++_j : --_j) {
            if (!App.grid.holdCell({
              i: i,
              j: j
            }, this)) {
              this.set('isValid', false);
              return false;
            }
          }
        }
        App.grid.refreshGrid();
        return true;
      };

      Block.prototype.removeSelf = function() {
        this.removeSelfFromGrid();
        return this.removeSelfFromDom();
      };

      Block.prototype.removeSelfFromGrid = function() {
        var endIJ, i, j, startIJ, _i, _j, _ref1, _ref2, _ref3, _ref4;

        startIJ = this.get('startIJ');
        endIJ = this.get('endIJ');
        for (i = _i = _ref1 = startIJ.i, _ref2 = endIJ.i; _ref1 <= _ref2 ? _i < _ref2 : _i > _ref2; i = _ref1 <= _ref2 ? ++_i : --_i) {
          for (j = _j = _ref3 = startIJ.j, _ref4 = endIJ.j; _ref3 <= _ref4 ? _j < _ref4 : _j > _ref4; j = _ref3 <= _ref4 ? ++_j : --_j) {
            App.grid.releaseCell({
              i: i,
              j: j
            }, this);
          }
        }
        return App.grid.refreshGrid();
      };

      Block.prototype.removeSelfFromDom = function() {
        return this.$el.remove();
      };

      Block.prototype.removeOldSelfFromGrid = function() {
        var i, j, _i, _j, _ref1, _ref2, _ref3, _ref4;

        if (this.buffStartIJ == null) {
          return;
        }
        for (i = _i = _ref1 = this.buffStartIJ.i, _ref2 = this.buffEndIJ.i; _ref1 <= _ref2 ? _i < _ref2 : _i > _ref2; i = _ref1 <= _ref2 ? ++_i : --_i) {
          for (j = _j = _ref3 = this.buffStartIJ.j, _ref4 = this.buffEndIJ.j; _ref3 <= _ref4 ? _j < _ref4 : _j > _ref4; j = _ref3 <= _ref4 ? ++_j : --_j) {
            App.grid.releaseCell({
              i: i,
              j: j
            }, this);
          }
        }
        return App.grid.refreshGrid();
      };

      return Block;

    })(ProtoClass);
    return Block;
  });

}).call(this);
