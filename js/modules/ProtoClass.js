// Generated by CoffeeScript 1.6.2
(function() {
  define('ProtoClass', function() {
    var ProtoClass;

    ProtoClass = (function() {
      function ProtoClass() {}

      ProtoClass.prototype.set = function(key, value) {
        var key1;

        if ((key != null) && typeof key === 'object') {
          for (key1 in key) {
            value = key[key1];
            this.setAttr(key1, value);
          }
        } else {
          this.setAttr(key, value);
        }
        return typeof this.onChange === "function" ? this.onChange() : void 0;
      };

      ProtoClass.prototype.setAttr = function(key, value) {
        return this[key] = value;
      };

      return ProtoClass;

    })();
    return ProtoClass;
  });

}).call(this);
