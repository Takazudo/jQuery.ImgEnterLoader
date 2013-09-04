do ($ = jQuery) ->

  EveEve = window.EveEve
  $win = $(window)
  ns = {}

  # ============================================================
  # throttle / debounce from underscore.js
  # http://documentcloud.github.com/underscore/

  ns.limit = (func, wait, debounce) ->
    timeout = null
    return ->
      context = this
      args = arguments
      throttler = ->
        timeout = null
        func.apply context, args

      clearTimeout timeout if debounce
      timeout = setTimeout(throttler, wait) if debounce or not timeout

  ns.throttle = (func, wait) ->
    return ns.limit func, wait, false

  ns.debounce = (func, wait) ->
    return ns.limit func, wait, true

  # ============================================================
  # loadImg

  ns.loadImg = (src) ->
    defer = $.Deferred()
    img = new Image
    cleanUp = -> img.onload = img.onerror = null
    img.onload = ->
      cleanUp
      defer.resolve img
    img.onerror = ->
      cleanUp
      defer.reject img
    img.src = src
    return defer.promise()

  # ============================================================
  # window utils

  ns.isAboveTheWindow = ($el, options) ->
    defaults =
      threshold: 0
    if $el.length > 1
      $.error "2 or more elements were thrown."
      return false
    o = $.extend {}, defaults, options
    return $win.scrollTop() >= $el.offset().top + o.threshold + $el.innerHeight()

  ns.isBelowTheWindow = ($el, options) ->
    defaults =
      threshold: 0
    if $el.size() > 1
      $.error "2 or more elements were thrown."
      return false
    o = $.extend {}, defaults, options
    return $win.height() + $win.scrollTop() <= $el.offset().top - o.threshold

  ns.isInWindow = ($el) ->
    return not (ns.isAboveTheWindow $el) and not (ns.isBelowTheWindow $el)

  # ============================================================
  # Winwatcher

  class ns.Winwatcher extends EveEve
    eventNames = 'resize scroll orientationchange'
    constructor: ->
      $win.bind eventNames, =>
        @trigger 'resize'

  # put instance under namespace
  ns.winwatcher = new ns.Winwatcher

  # ============================================================
  # Loader

  class ns.Loader

    @defaults =
      threshold: 0
      throttle_millisec: 200
      enter: $.noop
      imgsrc: null
      imgsrc_attr: 'data-enterload'
      imgload: ($container, $img) ->
        $img.hide()
        $container.append $img
        $img.fadeIn()
    
    constructor: (@$el, options) ->
      @loaded = false
      @options = $.extend {}, ns.Loader.defaults, options
      @imgsrc = @options.imgsrc or (@$el.attr @options.imgsrc_attr)
      @_watchResize()
      @check()

    check: ->
      if @loaded
        return
      if ns.isInWindow @$el
        @loaded = true
        @options.enter @$el
        (ns.loadImg @imgsrc).done (img) =>
          @options.imgload @$el, $(img)
        @_unwatchResize()
      
    # private
    
    _watchResize: ->
      @_resizeHandler = ns.throttle (=> @check()), @options.throttle_millisec
      ns.winwatcher.on 'resize', @_resizeHandler

    _unwatchResize: ->
      ns.winwatcher.off 'resize', @_resizeHandler
      
  # ============================================================
  # bridge to plugin

  $.fn.imgEnterLoad = (options) ->
    return @each (i, el) ->
      $el = $(el)
      instance = new ns.Loader $el, options
      $el.data 'imgenterloader', instance
      return

  # ============================================================
  # globalify

  $.ImgEnterLoaderNs = ns
  $.ImgEnterLoader = ns.Loader

