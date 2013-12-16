// Generated by CoffeeScript 1.6.2
(function() {
  define('grid', ['path-finder'], function(PathFinder) {
    var Grid;

    Grid = (function() {
      function Grid(o) {
        this.o = o != null ? o : {};
        this.w = this.o.width || 100;
        this.h = this.o.height || 100;
        this.pf = PathFinder;
        this.grid = new PathFinder.Grid(this.w, this.h);
        this.finder = new PathFinder.AStarFinder({
          allowDiagonal: true,
          dontCrossCorners: true
        });
        this.debugGrid = [];
        this;
      }

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

        ij = this.toIJ(coords);
        return this.grid.isWalkableAt(ij.i, ij.j);
      };

      Grid.prototype.holdCell = function(ij, obj) {
        ij = ij.x ? this.toIJ(ij) : ij;
        if (!this.grid.isWalkableAt(ij.i, ij.j)) {
          console.error('Hold cell error - current cell is already taken');
          return;
        }
        this.grid.setWalkableAt(ij.i, ij.j, false);
        return this.refreshGrid();
      };

      Grid.prototype.releaseCell = function(ij, obj) {
        ij = ij.x ? this.toIJ(ij) : ij;
        if (this.grid.isWalkableAt(ij.i, ij.j)) {
          console.warn('Release cell warning - current cell is already empty');
          return;
        }
        this.grid.setWalkableAt(ij.i, ij.j, true);
        return this.refreshGrid();
      };

      Grid.prototype.holdCellXY = function(coords, obj) {
        var ij;

        ij = this.toIJ(coords);
        return this.holdCell(ij, obj);
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

        from = this.toIJ(fromTo.from);
        to = this.toIJ(fromTo.to);
        this.gridBackup = this.grid.clone();
        return this.finder.findPath(from.i, from.j, to.i, to.j, this.gridBackup);
      };

      Grid.prototype.refreshGrid = function() {
        var i, j, rect, _i, _ref, _results;

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
              if ((this.grid.getNodeAt(i, j)).walkable === false) {
                rect = App.two.makeRectangle((i * App.gs) + (App.gs / 2), (j * App.gs) + (App.gs / 2), App.gs, App.gs);
                rect.fill = 'rgba(255,255,255,.15)';
                rect.noStroke();
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
          rect.remove();
        }
        return this.debugGrid.length = 0;
      };

      return Grid;

    })();
    return Grid;
  });

}).call(this);
