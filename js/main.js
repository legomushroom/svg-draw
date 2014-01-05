// Generated by CoffeeScript 1.6.2
(function() {
  require.config({
    paths: {
      jquery: 'lib/jquery-2.0.1',
      underscore: 'lib/lodash.underscore',
      hammer: 'lib/hammer',
      tween: 'lib/tween.min',
      md5: 'lib/md5',
      'path-finder': 'lib/pathfinding-browser',
      path: 'modules/path',
      block: 'modules/block',
      port: 'modules/port',
      line: 'modules/line',
      ProtoClass: 'modules/ProtoClass',
      backbone: 'lib/backbone'
    },
    shim: {
      "two": {
        exports: "Two"
      },
      backbone: {
        exports: 'Backbone',
        deps: ['jquery', 'underscore']
      }
    }
  });

  define('main', ['helpers', 'hammer', 'jquery', 'svg', 'path', 'block', 'grid', 'path-finder'], function(helpers, hammer, $, SVG, Path, Block, Grid, PathFinder) {
    var App;

    App = (function() {
      function App() {
        this.initVars();
        this.listenToTouches();
        this.listenToTools();
      }

      App.prototype.initVars = function() {
        this.$main = $('#js-main');
        this.$tools = $('#js-tools');
        this.helpers = helpers;
        this.gs = 16;
        this.grid = new Grid;
        this.paths = [];
        this.blocks = [];
        this.SVG = new SVG({
          $el: this.$main,
          grid: this.grid
        });
        this.debug = {
          isGrid: false,
          time: false
        };
        this.currTool = ['path', 'block'][0];
        this.$tools.find("[data-role=\"" + this.currTool + "\"]").addClass('is-check');
        return this;
      };

      App.prototype.listenToTouches = function() {
        var _this = this;

        this.currPath = null;
        hammer(this.$main[0]).on('touch', function(e) {
          switch (_this.currTool) {
            case 'path':
              return _this.touchPath(e);
            case 'block':
              return _this.touchBlock(e);
          }
        });
        hammer(this.$main[0]).on('drag', function(e) {
          switch (_this.currTool) {
            case 'path':
              return _this.dragPath(e);
            case 'block':
              return _this.dragBlock(e);
          }
        });
        return hammer(this.$main[0]).on('release', function(e) {
          switch (_this.currTool) {
            case 'path':
              return _this.releasePath(e);
            case 'block':
              return _this.releaseBlock(e);
          }
        });
      };

      App.prototype.releaseBlock = function(e) {
        this.currBlock.addFinilize();
        return this.blockDrag = false;
      };

      App.prototype.touchBlock = function(e) {
        var coords;

        coords = helpers.getEventCoords(e);
        if (!this.grid.isFreeCell(coords)) {
          return;
        }
        return this.currBlock = new Block({
          coords: coords
        });
      };

      App.prototype.dragBlock = function(e) {
        var coords, _ref;

        this.blockDrag = true;
        coords = helpers.getEventCoords(e);
        return (_ref = this.currBlock) != null ? _ref.setSizeDelta(this.grid.normalizeCoords({
          x: e.gesture.deltaX,
          y: e.gesture.deltaY
        })) : void 0;
      };

      App.prototype.touchPath = function(e) {
        var coords, pathEndCell;

        coords = helpers.getEventCoords(e);
        pathEndCell = this.grid.isPathEndCell(coords);
        if (pathEndCell) {
          this.currPath = pathEndCell;
          return;
        }
        if (!this.grid.isFreeCell(coords)) {
          this.currPath = null;
        } else {
          return this.addCurrentPath(coords);
        }
      };

      App.prototype.releasePath = function(e) {
        if (this.currPath) {
          this.currPath.currentAddPoint = null;
          return this.currPath.removeIfEmpty();
        }
      };

      App.prototype.dragPath = function(e) {
        var coords, point, _ref;

        coords = helpers.getEventCoords(e);
        if (this.grid.isFreeCell(coords)) {
          if (this.isBlockToPath) {
            this.currPath = this.isBlockToPath;
            return this.isBlockToPath = false;
          } else {
            point = this.currPath.currentAddPoint || 'endIJ';
            return (_ref = this.currPath) != null ? _ref.set(point, this.grid.toIJ(coords)) : void 0;
          }
        }
      };

      App.prototype.listenToTools = function() {
        var it;

        it = this;
        return $('#js-tools').on('click', '#js-tool', function(e) {
          var $this;

          $this = $(this);
          it.currTool = $this.data().role;
          return $this.addClass('is-check').siblings().removeClass('is-check');
        });
      };

      App.prototype.addCurrentPath = function(coords) {
        this.currPath = new Path({
          coords: this.grid.getNearestCellCenter(coords)
        });
        return this.paths.push(this.currPath);
      };

      return App;

    })();
    return window.App = new App;
  });

}).call(this);
