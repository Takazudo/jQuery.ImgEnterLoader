/*! jQuery.ImgEnterLoader (https://github.com/Takazudo/jQuery.ImgEnterLoader)
 * lastupdate: 2013-09-20
 * version: 0.1.0
 * author: 'Takazudo' Takeshi Takatsudo <takazudo@gmail.com>
 * License: MIT */
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  (function($) {
    var $win, EveEve, ns;
    EveEve = window.EveEve;
    $win = $(window);
    ns = {};
    ns.limit = function(func, wait, debounce) {
      var timeout;
      timeout = null;
      return function() {
        var args, context, throttler;
        context = this;
        args = arguments;
        throttler = function() {
          timeout = null;
          return func.apply(context, args);
        };
        if (debounce) {
          clearTimeout(timeout);
        }
        if (debounce || !timeout) {
          return timeout = setTimeout(throttler, wait);
        }
      };
    };
    ns.throttle = function(func, wait) {
      return ns.limit(func, wait, false);
    };
    ns.debounce = function(func, wait) {
      return ns.limit(func, wait, true);
    };
    ns.loadImg = function(src) {
      var cleanUp, defer, img;
      defer = $.Deferred();
      img = new Image;
      cleanUp = function() {
        return img.onload = img.onerror = null;
      };
      img.onload = function() {
        cleanUp();
        return defer.resolve(img);
      };
      img.onerror = function() {
        cleanUp();
        return defer.reject(img);
      };
      img.src = src;
      return defer.promise();
    };
    ns.isAboveTheWindow = function($el, options) {
      var defaults, o;
      defaults = {
        threshold: 0
      };
      if ($el.length > 1) {
        $.error("2 or more elements were thrown.");
        return false;
      }
      o = $.extend({}, defaults, options);
      return $win.scrollTop() >= $el.offset().top + o.threshold + $el.innerHeight();
    };
    ns.isBelowTheWindow = function($el, options) {
      var defaults, o;
      defaults = {
        threshold: 0
      };
      if ($el.size() > 1) {
        $.error("2 or more elements were thrown.");
        return false;
      }
      o = $.extend({}, defaults, options);
      return $win.height() + $win.scrollTop() <= $el.offset().top - o.threshold;
    };
    ns.isInWindow = function($el) {
      return !(ns.isAboveTheWindow($el)) && !(ns.isBelowTheWindow($el));
    };
    ns.Winwatcher = (function(_super) {
      var eventNames;

      __extends(Winwatcher, _super);

      eventNames = 'resize scroll orientationchange';

      function Winwatcher() {
        var _this = this;
        $win.bind(eventNames, function() {
          return _this.trigger('resize');
        });
      }

      return Winwatcher;

    })(EveEve);
    ns.winwatcher = new ns.Winwatcher;
    ns.Loader = (function() {

      Loader.defaults = {
        threshold: 0,
        throttle_millisec: 200,
        enter: $.noop,
        imgsrc: null,
        imgsrc_attr: 'data-enterload',
        imgload: function($container, $img) {
          $img.hide();
          $container.append($img);
          return $img.fadeIn();
        }
      };

      function Loader($el, options) {
        this.$el = $el;
        this.loaded = false;
        this.options = $.extend({}, ns.Loader.defaults, options);
        this.imgsrc = this.options.imgsrc || (this.$el.attr(this.options.imgsrc_attr));
        this._watchResize();
        this.check();
      }

      Loader.prototype.check = function() {
        var _this = this;
        if (this.loaded) {
          return;
        }
        if (ns.isInWindow(this.$el)) {
          this.loaded = true;
          this.options.enter(this.$el);
          (ns.loadImg(this.imgsrc)).done(function(img) {
            return _this.options.imgload(_this.$el, $(img));
          });
          return this._unwatchResize();
        }
      };

      Loader.prototype._watchResize = function() {
        var _this = this;
        this._resizeHandler = ns.throttle((function() {
          return _this.check();
        }), this.options.throttle_millisec);
        return ns.winwatcher.on('resize', this._resizeHandler);
      };

      Loader.prototype._unwatchResize = function() {
        return ns.winwatcher.off('resize', this._resizeHandler);
      };

      return Loader;

    })();
    $.fn.imgEnterLoad = function(options) {
      return this.each(function(i, el) {
        var $el, instance;
        $el = $(el);
        instance = new ns.Loader($el, options);
        $el.data('imgenterloader', instance);
      });
    };
    $.ImgEnterLoaderNs = ns;
    return $.ImgEnterLoader = ns.Loader;
  })(jQuery);

}).call(this);
