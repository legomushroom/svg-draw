// Generated by CoffeeScript 1.6.2
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define('path', ['jquery', 'helpers', 'ProtoClass', 'line', 'underscore'], function($, helpers, ProtoClass, Line, _) {
    var Path, _ref;

    Path = (function(_super) {
      __extends(Path, _super);

      function Path() {
        _ref = Path.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Path.prototype.type = 'path';

      Path.prototype.initialize = function(o) {
        this.o = o != null ? o : {};
        this.set('id', helpers.genHash());
        if (this.o.coords) {
          this.set({
            'startIJ': App.grid.toIJ(this.o.coords),
            'endIJ': App.grid.toIJ(this.o.coords)
          });
        }
        this.on('change:startIJ', _.bind(this.onChange, this));
        return this.on('change:endIJ', _.bind(this.onChange, this));
      };

      Path.prototype.onChange = function() {
        this.set('oldIntersects', helpers.cloneObj(this.get('intersects')));
        return this.render();
      };

      Path.prototype.render = function(isRepaintIntersects) {
        if (isRepaintIntersects == null) {
          isRepaintIntersects = false;
        }
        this.removeFromGrid();
        this.recalcPath();
        this.makeSvgPath();
        return App.grid.refreshGrid();
      };

      Path.prototype.pushPoint = function(ij, i) {
        var node, point, xy, _ref1;

        xy = App.grid.fromIJ(ij);
        node = App.grid.atIJ(ij);
        if ((_ref1 = node.holders) == null) {
          node.holders = {};
        }
        node.holders[this.get('id')] = this;
        point = {
          x: xy.x,
          y: xy.y,
          curve: null,
          i: i
        };
        this.points.push(point);
        return this.points;
      };

      Path.prototype.recalcPath = function() {
        var dir, endBlock, endBlockEndIJ, endBlockStartIJ, endH, endIJ, endW, glimps, i, ij, startBlock, startBlockEndIJ, startBlockStartIJ, startH, startIJ, startW, _i, _j, _ref1, _ref2, _ref3, _ref4;

        helpers.timeIn('path recalc');
        glimps = this.makeGlimps();
        this.points = [];
        startIJ = this.get('startIJ');
        endIJ = this.get('endIJ');
        dir = glimps.direction;
        this.direction = dir;
        startBlock = glimps.startBlock;
        endBlock = glimps.endBlock;
        startBlockEndIJ = startBlock.get('endIJ');
        startBlockStartIJ = startBlock.get('startIJ');
        endBlockEndIJ = endBlock ? endBlock.get('endIJ') : this.get('endIJ');
        endBlockStartIJ = endBlock ? endBlock.get('startIJ') : this.get('startIJ');
        startW = Math.ceil(startBlock.get('w') / 2);
        startH = Math.ceil(startBlock.get('h') / 2);
        endW = endBlock ? Math.ceil(endBlock.get('w') / 2) : 0;
        endH = endBlock ? Math.ceil(endBlock.get('h') / 2) : 0;
        if (dir === 'i') {
          if (startIJ.i < endIJ.i) {
            startIJ = {
              i: startBlockEndIJ.i,
              j: startIJ.j
            };
            endIJ = {
              i: endBlockStartIJ.i,
              j: endIJ.j
            };
          } else {
            startIJ = {
              i: startBlockStartIJ.i,
              j: startIJ.j
            };
            endIJ = {
              i: endBlockEndIJ.i,
              j: endIJ.j
            };
          }
        } else {
          if (startIJ.j < endIJ.j) {
            startIJ = {
              i: startIJ.i,
              j: startBlockEndIJ.j
            };
            endIJ = {
              i: endIJ.i,
              j: endBlockStartIJ.j
            };
          } else {
            startIJ = {
              i: startIJ.i,
              j: startBlockStartIJ.j
            };
            endIJ = {
              i: endIJ.i,
              j: endBlockEndIJ.j
            };
          }
        }
        for (i = _i = _ref1 = startIJ[dir], _ref2 = Math.ceil(glimps.base); _ref1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; i = _ref1 <= _ref2 ? ++_i : --_i) {
          if (dir === 'i') {
            ij = {
              i: i,
              j: startIJ.j
            };
          } else {
            ij = {
              i: startIJ.i,
              j: i
            };
          }
          this.pushPoint(ij, i);
        }
        for (i = _j = _ref3 = Math.ceil(glimps.base), _ref4 = endIJ[dir]; _ref3 <= _ref4 ? _j <= _ref4 : _j >= _ref4; i = _ref3 <= _ref4 ? ++_j : --_j) {
          if (dir === 'i') {
            ij = {
              i: i,
              j: endIJ.j
            };
          } else {
            ij = {
              i: endIJ.i,
              j: i
            };
          }
          this.pushPoint(ij, i);
        }
        this.set('points', this.points);
        this.calcPolar();
        helpers.timeOut('path recalc');
        return this;
      };

      Path.prototype.makeGlimps = function() {
        var baseDirection, end, endBlock, endBlockH, endBlockW, endIJ, returnValue, start, startBlock, startIJ, xBase, xDifference, yBase, yDifference;

        startIJ = this.get('startIJ');
        endIJ = this.get('endIJ');
        startBlock = this.get('connectedStart');
        endBlock = this.get('connectedEnd');
        endBlockW = !endBlock ? 0 : endBlock.get('w') / 2;
        endBlockH = !endBlock ? 0 : endBlock.get('h') / 2;
        if (startIJ.i < endIJ.i) {
          end = startIJ.i + startBlock.get('w') / 2;
          xDifference = (endIJ.i - endBlockW) - end;
          xBase = end + (xDifference / 2);
        } else {
          start = endIJ.i + endBlockW;
          xDifference = (startIJ.i - startBlock.get('w') / 2) - start;
          xBase = start + (xDifference / 2);
        }
        if (startIJ.j < endIJ.j) {
          end = startIJ.j + startBlock.get('h') / 2;
          yDifference = (endIJ.j - endBlockH) - end;
          yBase = end + (yDifference / 2);
        } else {
          start = endIJ.j + endBlockH;
          yDifference = (startIJ.j - startBlock.get('h') / 2) - start;
          yBase = start + (yDifference / 2);
        }
        baseDirection = xDifference >= yDifference ? 'i' : 'j';
        return returnValue = {
          direction: baseDirection,
          base: baseDirection === 'i' ? xBase : yBase,
          startBlock: startBlock,
          endBlock: endBlock
        };
      };

      Path.prototype.calcPolar = function() {
        var firstPoint, lastPoint, points;

        points = this.get('points');
        firstPoint = points[0];
        lastPoint = points[points.length - 1];
        this.set('xPolar', firstPoint.x < lastPoint.x ? 'plus' : 'minus');
        return this.set('yPolar', firstPoint.y < lastPoint.y ? 'plus' : 'minus');
      };

      Path.prototype.repaintIntersects = function(intersects) {
        var name, path;

        for (name in intersects) {
          path = intersects[name];
          if (path.id === this.id) {
            continue;
          }
          path.render([path.id]);
        }
        return this.set('oldIntersects', {});
      };

      Path.prototype.detectCollisions = function() {
        var myDirection, name, node, path, point, _i, _len, _ref1, _results,
          _this = this;

        this.set('intersects', {});
        _ref1 = this.get('points');
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          point = _ref1[_i];
          myDirection = this.directionAt(point);
          node = App.grid.at(point);
          if (_.size(node.holders) > 1) {
            _.chain(node.holders).where({
              type: 'path'
            }).each(function(holder) {
              return _this.set('intersects', (_this.get('intersects')[holder.id] = holder));
            });
            _results.push((function() {
              var _ref2, _results1;

              _ref2 = this.get('intersects');
              _results1 = [];
              for (name in _ref2) {
                path = _ref2[name];
                if (path.get('id' === this.get('id'))) {
                  continue;
                }
                if (myDirection !== path.directionAt(point) && path.directionAt(point) !== 'corner' && myDirection !== 'corner') {
                  _results1.push(point.curve = "" + myDirection);
                } else {
                  _results1.push(void 0);
                }
              }
              return _results1;
            }).call(this));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      Path.prototype.directionAt = function(xy) {
        var direction, point, points, _ref1, _ref2, _ref3, _ref4;

        points = this.get('points');
        point = _.where(points, {
          x: xy.x,
          y: xy.y
        })[0];
        if (!point) {
          return 'corner';
        }
        if (((_ref1 = points[point.i - 1]) != null ? _ref1.x : void 0) === point.x && ((_ref2 = points[point.i + 1]) != null ? _ref2.x : void 0) === point.x) {
          direction = 'vertical';
        } else if (((_ref3 = points[point.i - 1]) != null ? _ref3.y : void 0) === point.y && ((_ref4 = points[point.i + 1]) != null ? _ref4.y : void 0) === point.y) {
          direction = 'horizontal';
        } else {
          direction = 'corner';
        }
        return direction;
      };

      Path.prototype.makeSvgPath = function() {
        if (this.line == null) {
          return this.line = new Line({
            path: this
          });
        } else {
          return this.line.resetPoints(this.get('points'));
        }
      };

      Path.prototype.removeFromGrid = function() {
        var node, point, points, _i, _len, _results;

        points = this.get('points');
        if (points == null) {
          return;
        }
        _results = [];
        for (_i = 0, _len = points.length; _i < _len; _i++) {
          point = points[_i];
          node = App.grid.at(point);
          _results.push(delete node.holders[this.get('id')]);
        }
        return _results;
      };

      Path.prototype.removeIfEmpty = function() {
        if (this.isEmpty()) {
          this.line.remove();
          this.removeFromGrid();
        }
        return App.grid.refreshGrid();
      };

      Path.prototype.isEmpty = function() {
        var _ref1;

        return ((_ref1 = this.line) != null ? _ref1.get('points').length : void 0) <= 2;
      };

      return Path;

    })(ProtoClass);
    return Path;
  });

}).call(this);
