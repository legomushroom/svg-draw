// Generated by CoffeeScript 1.6.2
(function() {
  define('grid', ['path-finder', 'underscore'], function(PathFinder, _) {
    var Grid;

    Grid = (function() {
      function Grid(o) {
        this.o = o != null ? o : {};
        this.w = this.o.width || 100;
        this.h = this.o.height || 100;
        this.pf = PathFinder;
        this.grid = new PathFinder.Grid(this.w, this.h);
        this.finder = new PathFinder.IDAStarFinder({
          allowDiagonal: true,
          dontCrossCorners: true,
          heuristic: this.pf.Heuristic.manhattan
        });
        this.debugGrid = [];
        this.highLights = {};
        this;
      }

      Grid.prototype.holdCell = function(ij, obj) {
        var node;

        ij = ij.x ? this.toIJ(ij) : ij;
        node = this.grid.getNodeAt(ij.i, ij.j);
        if ((node.block != null) && (node.block.id !== obj.id)) {
          console.error('Hold cell error - current cell is already taken');
          return false;
        }
        node.block = obj;
        return true;
      };

      Grid.prototype.releaseCell = function(ij, obj) {
        var node, _ref;

        ij = ij.x != null ? this.toIJ(ij) : ij;
        node = this.grid.getNodeAt(ij.i, ij.j);
        if (((_ref = node.block) != null ? _ref.id : void 0) === obj.id) {
          return node.block = null;
        }
      };

      Grid.prototype.atIJ = function(ij) {
        return this.grid.getNodeAt(ij.i, ij.j);
      };

      Grid.prototype.at = function(xy) {
        var ij;

        ij = this.normalizeCoords(xy);
        return this.grid.getNodeAt(ij.i, ij.j);
      };

      Grid.prototype.normalizeCoords = function(coords) {
        if (coords.x != null) {
          return this.toIJ(coords);
        } else {
          return coords;
        }
      };

      Grid.prototype.getNearestCell = function(coords) {
        var result, x, y;

        x = App.gs * ~~(coords.x / App.gs);
        y = App.gs * ~~(coords.y / App.gs);
        return result = {
          x: x,
          y: y
        };
      };

      Grid.prototype.getNearestCellCenter = function(coords) {
        var result;

        coords = this.getNearestCell(coords);
        return result = {
          x: coords.x + (App.gs / 2),
          y: coords.y + (App.gs / 2)
        };
      };

      Grid.prototype.getGapPolyfill = function(fromTo) {
        var from, to;

        from = fromTo.from;
        to = fromTo.to;
        if (from.x) {
          from = this.toIJ(from);
          to = this.toIJ(to);
        }
        this.gridBackup = this.grid.clone();
        return this.finder.findPath(from.i, from.j, to.i, to.j, this.gridBackup);
      };

      Grid.prototype.toIJ = function(coords) {
        var result;

        return result = {
          i: ~~(coords.x / App.gs),
          j: ~~(coords.y / App.gs)
        };
      };

      Grid.prototype.fromIJ = function(ij) {
        var result;

        return result = {
          x: ij.i * App.gs + (App.gs / 2),
          y: ij.j * App.gs + (App.gs / 2)
        };
      };

      Grid.prototype.isFreeCell = function(coords) {
        var ij;

        if (coords.x) {
          ij = this.toIJ(coords);
        } else {
          ij = coords;
        }
        return this.grid.isWalkableAt(ij.i, ij.j);
      };

      Grid.prototype.isPathEndCell = function(coords) {
        var holders, node, path;

        coords = this.normalizeCoords(coords);
        node = this.grid.getNodeAt(coords.i, coords.j);
        holders = node.holders;
        if (holders) {
          path = holders[Object.keys(holders)[0]];
        }
        if (path && path.get('startIJ').i === coords.i && path.get('startIJ').j === coords.j) {
          path.currentAddPoint = 'startIJ';
        }
        return path;
      };

      Grid.prototype.highlightCell = function(coords) {
        var attrs, i, j, rect;

        if (this.highLights["" + coords.i + coords.j]) {
          return;
        }
        i = coords.i;
        j = coords.j;
        attrs = {
          x: "" + i + "em",
          y: "" + j + "em",
          width: "1em",
          height: "1em",
          fill: 'rgba(0,255,0,.5)'
        };
        rect = App.SVG.createElement('rect', attrs);
        App.SVG.lineToDom(rect);
        return this.highLights["" + coords.i + coords.j] = rect;
      };

      Grid.prototype.lowlightCell = function(coords) {
        if (this.highLights["" + coords.i + coords.j]) {
          App.SVG.removeElem(this.highLights["" + coords.i + coords.j]);
          return this.highLights["" + coords.i + coords.j] = null;
        }
      };

      Grid.prototype.refreshGrid = function() {
        var attrs, i, j, rect, _i, _ref, _results;

        if (!App.debug.isGrid) {
          return;
        }
        this.clearGrid();
        _results = [];
        for (j = _i = 0, _ref = this.h; 0 <= _ref ? _i < _ref : _i > _ref; j = 0 <= _ref ? ++_i : --_i) {
          _results.push((function() {
            var _j, _ref1, _results1;

            _results1 = [];
            for (i = _j = 0, _ref1 = this.w; 0 <= _ref1 ? _j < _ref1 : _j > _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
              if (_.size((this.grid.getNodeAt(i, j)).holders) || ((this.grid.getNodeAt(i, j)).block != null)) {
                attrs = {
                  x: "" + i + "em",
                  y: "" + j + "em",
                  width: "1em",
                  height: "1em",
                  fill: 'rgba(255,255,255,.15)'
                };
                rect = App.SVG.createElement('rect', attrs);
                App.SVG.lineToDom(null, rect);
                _results1.push(this.debugGrid.push(rect));
              } else {
                _results1.push(void 0);
              }
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };

      Grid.prototype.clearGrid = function() {
        var rect, _i, _len, _ref;

        _ref = this.debugGrid;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          rect = _ref[_i];
          App.SVG.removeElem(rect);
        }
        return this.debugGrid.length = 0;
      };

      return Grid;

    })();
    return Grid;
  });

}).call(this);

/*
//@ sourceMappingURL=grid.map
*/
