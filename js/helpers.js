// Generated by CoffeeScript 1.6.2
(function() {
  define('helpers', ['two'], function(Two) {
    var helpers;

    helpers = {
      arrayRemove: function(from, to) {
        var rest;

        rest = this.slice((to || from) + 1 || this.length);
        this.length = (from < 0 ? this.length + from : from);
        return this.push.apply(this, rest);
      },
      getEventCoords: function(e) {
        return {
          x: e.gesture.center.pageX,
          y: e.gesture.center.pageY
        };
      },
      timeIn: function(name) {
        return console.time(name);
      },
      timeOut: function(name) {
        return console.timeEnd(name);
      },
      genHash: function() {
        return md5((new Date) + (new Date).getMilliseconds() + Math.random(9999999999999) + Math.random(9999999999999) + Math.random(9999999999999));
      },
      makePoint: function(x, y) {
        var v;

        if (arguments.length <= 1) {
          y = x.y;
          x = x.x;
        }
        v = new Two.Vector(x, y);
        v.position = new Two.Vector().copy(v);
        return v;
      }
    };
    return helpers;
  });

}).call(this);
