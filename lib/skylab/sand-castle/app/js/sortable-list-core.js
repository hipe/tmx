function SkylabSortableListCore( listElem ) {

/*
  # synopsis

  this is the "core" implementation of a sortable list, intended to look
  and feel like the sorting interface for iPhone's "reminders" app (at least,
  its look at feel at this moment). (this design is probably elsewhere too.)

  we say "core" because this code itself is not packaged as e.g. an angular
  directive or jQuery plugin; but rather it is intended to serve as the
  "backend" for such plugins as we create them. this decoupling is by
  design, so that we are not anchored to any one framework's ecosystem, but
  rather so we are buoyed by all of them; while being insulated from their
  occasionally capricous API's.

  that said, we chain ourselves lightly to a couple of them:

  # requirements

    • some particular jQuery version (but only for selectors in a few places)
    • some particluar GSAP (for implementation of drag, animations)

  # features

  (while each of these features is "out there" somewhere already, we haven't
  been able to find all of them together in any *one* of our predecessors:)

    • one does not merely move the list item by dragging anywhere on the item:
      you must drag it by its "handle" (what we call a "scrubber" here).
      allows for the whole list to be itself draggable for other purposes.

    • multiple such lists may coexist on the same page - variables are
      "correctly" scoped.

    • GSAP for (sexy-assed) animations.

    • each tile may be of non-uniform, arbitrary height - there is no "grid".
      the appearance of each tile is not dictated by the plugin, but by the
      existing DOM.

    • implementation style:
      * jquery selectors are not littered throughout the code.
      * adds only one constant to the global namespace.

  # TO-DO's / wishlist / known issues

    • TODO: use triggers for your "scrubbers": http://greensock.com/draggable
    • TODO: lock axis (same source)
    • TODO: turn some display constants into options as needed..
    • [ more may exist below ]

  */

 /* # "constants" (and defaults for possible future options)

    credit is due: for those below values that govern appearance (e.g
    animation), they mostly come from "OSUBlake"'s
    [sortable demo] (http://codepen.io/osublake/pen/RNLdpz)
    which was insturmental in getting this whole thing started generally.

    ## coding conventions introduced

    • variables with two leading underscores are only used once ever..
 */

  var ACHIEVED = true;
  var debug = true;
  var __shadow2 = "0 6px 10px 0 rgba(0, 0, 0, 0.3), 0 2px 2px 0 rgba(0, 0, 0, 0.2)";
  var __moment = 0.2;  // ~ cheeky names for amount of time
  var waltz = 0.35;

 /*
    # section 1 - detecting when a drag session should start

    a "drag session" may result in zero to many "re-orderings", as the user
    drags the moving tile up and down, etc, before releasing it.

    the plug-in does not concern itself with whether these intermediate
    re-orderings are more significant than the final order at the end of the
    drag session. it (TODO) only emits events, one for each new order
    (including these intermediate orderings).

    the drag session ends "on release", not "on drag end" - we want to know
    that a release happened even if the "moving tile" wasn't moved at all.

    by design, we hold that there is no state to maintain in between drag
    sessions - after tiles go thru their final reordering for the drag
    session (or even when no re-ordering occurred), any permanent changes
    are reflected in the DOM (perhaps only in the CSS properties) and/or by
    events that we emit to handlers, that express the new order.

    the cost of the above is that we index all of the items sometimes
    redundantly on each touch. we accept this cost for these reasons:

      • having any long-running state between drag sessions gives us
        more surface area to test.

      • outside agents may mutate our model in between drag sessions (for
        example, adding or removing items). accomodating this is easier if
        we cache nothing.

    ## concepts introduced

    • "drag session"

    • "tile": the "physical" dom element that can be moved (or a jQuery
              selection around same.)

    • "moving tile": the tile being dragged by the user. (note that other
                     tiles may move during a drag session as a response to
                     a re-ordering. we call these "displaced tiles".)

    • "displaced tiles": see previous bullet. depending on context, does or
                         does not include the "moving tile".

    ## coding conventions introduced

    • variables & functions that exist only for readability (and not for re-
      use per se) have names with one and two leading underscores respectively.

    • we are commenting this module more heavily than usual for reasons.
 */

  $( '.scrubber', listElem ).mousedown( __onScrubberTouch );

  function __onScrubberTouch() {

    var scrubber = $( this );
    var movingTile;

    var ok;
    __findMovingTileFromScrubber();
    ok && __dragSessionIsNotAlreadyStarted();
    ok && __startDragSession( movingTile, scrubber );

    function __findMovingTileFromScrubber() {

      // find the tile element as a parent of the scrubber element. we allow
      // that the "scrubber" and "tile" could be the same element.

      var current = scrubber;
      do {
        if ( current.hasClass( 'tile' ) ) {
          var found = current;
          break;
        }
        current = current.parent();

      } while ( current.length );

      if ( found ) {
        movingTile = found;
        ok = ACHIEVED;
      } else {
        ok = error( "parent tile of scrubber not found (no \"tile\" class)" );
      }
    }

    function __dragSessionIsNotAlreadyStarted() {

      var drg = Draggable.get( movingTile );
      if ( drg ) {
        ok = error( "drag already in session? ignoring touch." );
      } else {
        ok = ACHIEVED;
      }
    }
  }

 /*
    # section 2 - indexing items and listening for drags

    hackily: although it is only the scrubber we use to detect the touch, we
    apply Draggable to the whole surrounding tile so that the whole tile
    moves in response to user moves; even though conceptually we pretend it
    is only the scrubber that is being dragged.

    fortunately the collateral damage of this is limited: because the
    surrounding tile picks up each of the four kinds of events we care about,
    the rest of the code need be none the wiser of this hack.

    ## waypoint/threshold theory

    the central function of this whole thing is to detect when to trigger a
    "displacement" (i.e. re-ordering) of the surrounding tiles based on the
    movement of the moving tile. we do this thru the use of "thresholds" and
    "waypoints".

    we imagine that the vertical center of the scrubber of the tile being
    dragged forms an imaginary horizontal "cursor". then we imagine that any
    above tile and below tile have imaginary lines thru their vertical
    centers (this time of the whole tile, not the scrubber) that we call
    "thresholds". once (if ever) the cursor "breaches" (hits or passes) one
    of these zero, one or two thresholds; this is what triggers a re-ordering.

    each time a threshold is breached and reordering is begun, we update our
    "waypoint" to reflect the new normal center of the scrubber. we use this
    value to determine whether the position of the scrubber at this moment is
    above or below its "resting position", so as to determine whether to
    test the above or below threshold.

    also, with each new waypoint we get two new thresholds, reflecting the
    vertical center of any new above and below tile of the moving tile.

    ## coding conventions introduced

    • we add a *trailing* underscore to a variable to differentiate it from
      another otherwise same-named variable in a nearby scope.
  */

  function __startDragSession( movingTile, scrubber ) {

    var itemIndex = __buildItemIndex();
    if (itemIndex) {
      __listen();
    }

    function __buildItemIndex(){

      var itemIndexAttempt = new __ItemIndex( movingTile, scrubber );
      var _ok = itemIndexAttempt.execute();
      if (_ok) {
        return itemIndexAttempt;
      }
    }

    var killable;
    function __listen(){

      killable = Draggable.create( movingTile, {
        bounds: listElem,
        onPress: __onPress,
        onDragStart: __onDragStart,
        onDrag: __onDrag,
        onRelease: __onRelease,
        zIndexBoost: false
      })[ 0 ];
    }

    // we only ever care about Y, not X. we don't have to care what the
    // coordinate system is (i.e what "0" means); only that it is downwards,
    // and that all of this code is using that same system (whatever it is).

    var movingItem;
    var pointerToScrubberCenterDelta;  // a few pixels
    var scrubberCenterWaypoint;

    function __onPress() {

      movingItem = itemIndex.movingItem();

      var scrubberCenterY = movingItem.scrubberCenterY();
      scrubberCenterWaypoint = scrubberCenterY;
      pointerToScrubberCenterDelta = scrubberCenterY - this.pointerY;
      reestablishThresholds();

      movingItem.whenPress();
    }

    function __onDragStart() {
      // nothing for now..
    }

    var checkUpperThreshold, checkLowerThreshold, scrubberCenterY;
    function __onDrag() {

      scrubberCenterY = this.pointerY + pointerToScrubberCenterDelta;

      if (scrubberCenterWaypoint > scrubberCenterY) {

        checkUpperThreshold();
      } else if (scrubberCenterWaypoint < scrubberCenterY) {

        checkLowerThreshold();
      }
    }

    function __onRelease(){

      stopListening();  // because we create a new draggable for each session
      movingItem.snapToIntendedLocation();  // see
    }

    function reestablishThresholds() {

      var prevItem = movingItem.previousItem();
      var nextItem = movingItem.nextItem();

      if (prevItem) {

        var aboveTileCenterY = prevItem.tileCenterY();

        checkUpperThreshold = function() {

          if (aboveTileCenterY >= scrubberCenterY) {
            whenBreached( true );
          }
        }
      } else {
        checkUpperThreshold = whenNoThreshold;
      }

      if (nextItem) {

        var belowTileCenterY = nextItem.tileCenterY();

        checkLowerThreshold = function() {

          if ( belowTileCenterY <= scrubberCenterY ) {
            whenBreached( false );
          }
        }
      } else {
        checkLowerThreshold = whenNoThreshold;
      }

      if (debug) {
        var a = [];
        if (prevItem) {
          a.push( "upper t.h: " + aboveTileCenterY );
        } else {
          a.push( "no upper t.h." );
        }
        if (nextItem) {
          a.push( "lower t.h: " + belowTileCenterY );
        } else {
          a.push( "no lower t.h." );
        }
        console.log( a.join(' ') );
      }
    }

    function whenNoThreshold(){}

    function whenBreached( isUpper ) {

      var _ok = __reorder( isUpper, scrubberCenterY, itemIndex );
      if (_ok) {
        scrubberCenterWaypoint = movingItem.tileCenterY();
        reestablishThresholds();
      } else {
        error( "reordering not ok?" );
        stopListening();
      }
    }

    function stopListening() {
      killable.kill();
    }
  }

 /* # section 3 - reordering

    1) assemble all displaced items (including the moving item) into an array
       that is in the correct order of the items' intended positions. (the
       moving item will always be either at the top or bottom of this array
       as appropriate.)

    2) correct the links of this assembly, taking care to correct links of
       any items that were before or after the displaced segment (but not
       themselves displaced).

    3) streaming along each displaced tile from the (new) top to bottom tile,
       calculate a new "top" value for each tile using simple arithmetic
       adding to each previous top value the previous tile's height and a
       gutter somehow.
  */

  function __reorder( breachedUpper, scrubberCenterY, itemIndex ) {

    var items = itemIndex.items;

    var movingItem = itemIndex.movingItem();

    var originalTopItem, originalBottomItem;

    var newOrder, origOrder;

    __determineNewOrder();

    __correctLinks();

    var _ok = __calculateNewTopsAndAnimate( newOrder, origOrder, itemIndex );

    return _ok;

    function __correctLinks() {

     /* for N items that are rearranged (where N is at least 2), there are
        always N+1 "joints" that need correcting: there is every 2-way joint
        between the N items (which is N-1 joints), and a "joint" before and
        a "joint" after. when the block of re-arranged items occurs at the
        beginning and or end of all the items, special handling is required.

        we make a stream function for these participating items, taking the
        above special handling into account:
      */

      var anyStationaryUpper = originalTopItem.previousItem();
      var anyStationaryLower = originalBottomItem.nextItem();
      var next, rest;

      var body = streamViaMap( streamViaArray( newOrder ), function( id ) {
        return items[ id ];
      });

      if (anyStationaryLower) {
        rest = function() {
          var x = body();
          if (x) {
            return x;
          } else {
            next = function(){ return null; };
            return anyStationaryLower;
          }
        }
      } else {
        rest = body;
      }

      if (anyStationaryUpper) {
        next = function() {
          next = rest;
          return anyStationaryUpper;
        };
      } else {
        next = rest;
      }

      var first = next();

      // if the block of rearrangement is anchored to the beginning:

      if (!anyStationaryUpper) {
        first.previousItemIdentifier = null;
        itemIndex.identifierOfHeadItem = first.id;
      }

      // breaches always involve at last two items

      var prev = first;
      var curr = next();

      // correct each joint from top to bottom

      do {
        prev.twoWayJoinToNext( curr );
        prev = curr;
        curr = next();
      } while (curr);

      // if the block of rearrangement is anchored to the end:

      if (!anyStationaryLower) {
        prev.nextItemIdentifier = null;
      }

      // (otherwiswe whatever item used to follow it still follows it)
    }

    function __determineNewOrder() {

      var a = [];
      var a_, next, yes;

      var origOrd = [];

      var curr = movingItem;

      if (breachedUpper) {  // if you breached the upper threshold
        a.push( movingItem.id );  // then first item (new order) is the moving item

        // you will go backwards over each previously above item of the moved
        // item until you find one that was not passed over by the move.

        // because we are going backwards (upwards), we will need to reverse
        // these items when they are done so they are top-down.

        a_ = [];  // a temp array that will be reversed

        next = function() {
          curr = curr.previousItem();
          return curr;
        };

        yes = function( item ) {
          // the item should be displaced if its vert center is below scrubber
          return scrubberCenterY <= item.tileCenterY();
        };

        originalBottomItem = movingItem;

      } else {

        // since you breached the lower threshold, we will test each next item
        // that used to be below the moving piece in order until we find one we
        // didn't pass over.

        a_ = a;  // there is no temp array. write directly to target destination

        next = function() {
          origOrd.push( curr.id );  // tricky
          curr = curr.nextItem();
          return curr;
        };
        yes = function( item ) {
          // the item should be displaced if its vert center is above scrubber
          return scrubberCenterY >= item.tileCenterY();
        };
        originalTopItem = movingItem;
      }

      var item;
      while (item = next()) {
        if ( yes( item ) ) {
          a_.push( item.id );
        } else {
          break;
        }
      }

      if (breachedUpper) {

        originalTopItem = items[ a_[ a_.length - 1 ] ];

        // the temp array is in reverse order of the desired order.
        // effectively reverse then concat the tmp ary onto destination ary.

        var i = a_.length;
        while (i--) {
          var d = a_[ i ];
          a.push( d );
          origOrd.push( d );
        }

        origOrd.push( movingItem.id );
      } else {

        originalBottomItem = items[ a[ a.length - 1 ] ];

        // when you breached lower, moving item is always the last item

        a.push( movingItem.id );
      }

      newOrder = a;
      origOrder = origOrd;
    }  // __determineNewOrder
  }  // __reorder

  function __calculateNewTopsAndAnimate( newOrd, oldOrd, idx ) {

   /* calculate and apply a new "top" for every displaced tile (including
      the tile that was dragged). using their intended final positions, we
      calculate these new tops from the topmost moved tile downwards, using
      appropriate addition at each step, taking into account each relevant
      height of the above tile and previous "gutter" as necessary.
    */

    var items = idx.items;

    function f( d ) { return items[ d ]; }

    // in the old order for N rearranged tiles, calculate a cached array of
    // N-1 "gutters" (the space between adjacent tiles). we do this in a
    // separate pass because we have to access the old tops.

    var next = streamViaMap( streamViaArray( oldOrd ), f );
    var gutters = [];

    var prev = next();  // orig top
    var curr = next();
    var origFirst = prev;
    do {

      gutters.push( curr.cachedTop - ( prev.cachedTop + prev.height() ) );

      prev = curr;
      curr = next();
    } while (curr);

    var nextGutter = streamViaArray( gutters );
    next = streamViaMap( streamViaArray( newOrd ), f );

    prev = next();  // new top
    curr = next();

    prev.prevTop = prev.cachedTop;
    prev.cachedTop = origFirst.cachedTop;  // let this be the last old top we use
    prev.whenNewTop();

    do {

      curr.prevTop = curr.cachedTop;
      curr.cachedTop = prev.cachedTop + prev.height() + nextGutter();

      curr.whenNewTop();  // animate now (but you could do it later instead)

      prev = curr;
      curr = next();
    } while (curr);

    return ACHIEVED;
  }

 /* # "animation" section

    ## conventions introduced:

    • "method" names with only a single leading underscore are private
      to the structure they are defined in.
  */

  function __animationMethods( o ) {

    o.whenPress = function() {

      // intended for the tile that is probably about to be dragged.

      var el = this.element();
      var tl = new TimelineLite();

      this.topBeforeDrag = this.cachedTop;

      this.hacky_original_Y_transform =
        __Y_transform_of( el.css( 'transform' ) );

      // "click" into the closer z-index before you tween

      tl.to( el, 0, { zIndex: 1 } );

      // tween to be slightly transparent and sligtly smaller, and with shadow

      tl.to( el,  __moment, {
        autoAlpha: 0.75,
        boxShadow: __shadow2,
        scale : 0.95,
      });

      this._playAsOnlyTimeline( tl );
    };

    o.snapToIntendedLocation = function() {

     /* the converse of the above method. the item has stopped moving now.
        it could be anywhere. get it from where it is to where it needs to be.

        ## the drift problem <a name='the-drift-problem'></a>

        EEK: bear in mind that the tile is now "anywhere" the user dragged
        it to, and it needs to go to its intended location. since this tile
        is by default "shrunken" (has a scale tranform on it), jQuery's
        `position()` method will (reasonably) take this scale into account
        when calculating the `position()`. (the "top" of a shrunken element
        will be a larger Y value than if the element were full-size, all
        other aspects being equal.)

        however, we are transforming it back to normal size as we move it.
        hence we don't want the scale tranform of the element to interfere
        with us getting a "pure" reading of this imaginary normal top hence
        we can't use jQuery's `position()` method. SO:

        1) we memoize what the Y transform was on the tile right before
           we started dragging it.

        2) take the Y value delta between where it used to be (before we
           started dragging it) and its intended location now (not where
           it actually is).

        3) apply this delta to the Y transform from (1) (with our code), then
           you have the *absolute* (not relative) transform necessary to move
           this piece to its intended location (right?).

        this sounds complicated, but without this accomodation we have a very
        real "drift" problem with each drag session, of by about 2.5% of the
        height of the moving tile.
      */

      var orig_Y_transform = this.hacky_original_Y_transform

      if ( false === orig_Y_transform ) {

        error( "fix me - no original Y transform value available." );

      } else {

        var el = this.element();
        var tl = new TimelineLite();

        var _cleanDelta = this.cachedTop - this.topBeforeDrag;
        var _intended_Y_transform = orig_Y_transform + _cleanDelta;

        // to the converse of the above - move it back etc.

        tl.to( el, waltz, {
          autoAlpha: 1, // 0.75,
          boxShadow: 'none', // __shadow2,
          scale : 1,  //0.95,
          x: 0,
          y: _intended_Y_transform,
        });

        // once it is back in place, bump the z-index down to zero so that
        // when future tiles are dragged over this one, that tile is closer

        tl.to( el, 0, {
          zIndex: 0
        });

        this._playAsOnlyTimeline( tl );
      }
    };

    o.whenNewTop = function() {

     /* this default implementation is intended for those tiles that are
        displaced but are not the tile being dragged. note that they may be
        in the middle of an existing animation when this message is received.
        note too that they may have existing transforms on them from previous
        moves, which is why we send the translation in relative terms.
     */

      // don't incur the cost of calculating the real top unless you have to..

      if ( this.timeline ) {
        this._stopExistingTimeline();
        var _currentTop = this.element().position().top;
        var delta = this.cachedTop - _currentTop;
      } else {
        delta = this.cachedTop - this.prevTop;
      }

      var tl = new TimelineLite();

      var _s = __relativePixelsStringViaDelta( delta );

      tl.to( this.element(), waltz, {
        y: _s
      });

      this._playAsOnlyTimeline( tl );
    };

    o._playAsOnlyTimeline = function( tl ) {

      if ( this.timeline ) {
        this._stopExistingTimeline();
      }

      this.timeline = tl;

      var me = this;
      tl.eventCallback( "onComplete", function() {
        me.timeline = null;
      });

      tl.play();
    };

    o._stopExistingTimeline = function() {

      this.timeline.pause();  // there is no stop() for tweens..
      this.timeline = null;
    };

   /* ### parse our own CSS :(

      (see [the drift problem] (#the-drift-problem))
    */

    // matrix( scale skew rotate alpha X Y )

    var __Y_transform_of = __buildMatrixMatcher( 5 );

    function __buildMatrixMatcher( d ) {

      var f = function( s ) {
        f = __buildMatcher( d, 'matrix' );
        return f( s );
      };
      return function( s ) {
        return f( s );
      };
    }

    function __buildMatcher( d, termString ) {

      var rx = __buildRegExp( d, termString );

      return function( s ) {
        var md = rx.exec( s );
        if (md) {
          return Number( md[ 1 ] );
        } else {
          return false;
        }
      };
    }

    function __buildRegExp( d, s ) {

      var a = [ '^' + s + '\\(' ];
      var a_ = [];
      if ( 0 < d ) {
        var i = d;
        while (i--) {
          a_.push( numberRxs );
        }
      }

      a_.push( '(' + numberRxs + ')' );

      var d_ = 5 - d;
      if ( 0 < d_ ) {
        i = d_;
        while (i--) {
          a_.push( numberRxs );
        }
      }

      a.push( optionalSpaceRxs );
      a.push( a_.join( ',[ ]*' ) );
      a.push( optionalSpaceRxs );

      a.push( '\\)$' );

      return RegExp( a.join( '' ) );
    }

    var numberRxs = '-?\\d+(?:\\.\\d+)?(?:e-?\\d+)?';
    var optionalSpaceRxs = '[ ]*';

  };

  function __relativePixelsStringViaDelta( delta ) {

    if ( 0 > delta ) {
      return '-=' + ( -1 * delta ) + 'px';
    } else {
      return '+=' + ( delta ) + 'px';
    }
  }

 /* # "model" section - for modeling the items
  */

  function __ItemIndex( movingTile, scrubber ) {

    // items, identifierOfHeadItem, identifierOfMovingItem

    this.execute = function() {

      var ok = __catalogItems( this, movingTile, scrubber );
      ok && ( ok = __sortAndLinkItems( this ) );
      ok && debug && console.log( this.description() );
      this.execute = null;
      return ok;
    };

    Object.setPrototypeOf( this, __ItemIndexMethods );
  }

  var __ItemIndexMethods = {

    description: function() {
      var a = []
      var curr = this.headItem();
      while (curr) {
        a.push( curr.description() );
        curr = curr.nextItem();
      }
      return '(' + a.join( ',' ) + ')'
    },

    headItem: function() {
      return this.items[ this.identifierOfHeadItem ];
    },

    movingItem: function() {
      return this.items[ this.identifierOfMovingItem ];
    }
  };

  function __catalogItems( results, movingTile, scrubber ) {

    // we store values that we consider to be "immutable" (in some regard)
    // separate from mutable, in case that ends up becoming useful..

    var mutables = [];  // elements are struct-like
    var immutables = [];  // parallel with above, elements are object-like

    var moving_DOM_element = movingTile[ 0 ];
    var next = streamViaArray( listElem.children() );

    var itemPrototype = {  // defined here because closes around above

      description: __describeItemMethod,

      tileCenterY: function() {
        return this.cachedTop + immutables[ this.id ].radius;
      },

      radius: function() {
        return immutables[ this.id ].radius;
      },

      height: function() {
        return immutables[ this.id ].height;
      },

      element: function() {
        return immutables[ this.id ].element;
      }
    };

    function __lookup( id ) {
      if ( null == id ) {
        return null;
      } else {
        return mutables[ id ];
      }
    }

    __linkedListMethods( itemPrototype, __lookup );
    __animationMethods( itemPrototype );

    var identifierOfMovingItem = null;

    // catalog each item when we don't know which is the moving item

    var tile;
    while ( tile = next() ) {

      if ( moving_DOM_element == tile ) {
        __addMovingItem();
        break;
      } else {
        addNonMovingItem();
      }
    }

    // because we've found the moving item we don't have to look for it.

    while ( tile = next() ) {
      addNonMovingItem();
    }

    function __addMovingItem() {

      var d = beginItem();
      immutables[ d ].element = movingTile;
      finishItem( d );
      var item = mutables[ d ]

      var __scrubberCenterDepthInItem_ = __scrubberCenterDepthInItem( item );
      item.scrubberCenterY = function() {
        return item.cachedTop + __scrubberCenterDepthInItem_;
      };

      item.whenNewTop = function() {
        // the tile being dragged does nothing with the
        // notification of a new top *at this point*.
      }

      identifierOfMovingItem = d;
    }

    function __scrubberCenterDepthInItem( item ) {

     /* WARNING - what "top" means is CSS dependant - the below calcuation
        asssumes that the tiles are `position: relative`. (they must be so
        so that their z-index is honored.) when the tiles were not, the below
        reported "top" was a top in our "normal" coordinates.
      */

      var _localTop = scrubber.position().top;  // when tile is pos:relative.
      // you would have to subtract `item.cachedTop` if tile were not.

      var _ht = scrubber.height();
      return _localTop + ( _ht / 2 );
    }

    function addNonMovingItem() {

      var d = beginItem();
      immutables[ d ].element = $( tile );
      finishItem( d );
    }

    function beginItem() {

      var d = immutables.length;
      immutables[ d ] = {};
      mutables[ d ] = { id: d };
      return d;
    }

    function finishItem( d ) {

      var im = immutables[ d ];
      var mu = mutables[ d ];

      var el = im.element;

      var h = el.height();
      im.height = h;
      im.radius = h / 2;

      var top = el.position().top;
      mu.cachedTop = top;

      Object.setPrototypeOf( mu, itemPrototype );
    }

    if ( null == identifierOfMovingItem ) {
      return error( "moving item not found" );
    } else {
      results.items = mutables;
      results.identifierOfMovingItem = identifierOfMovingItem;
      return ACHIEVED;
    }
  }  // __catalogItems

  function __sortAndLinkItems( self ) {  // set identifierOfMovingItem

    var items = self.items;

    // let "a" be an array of ID's to items, sorted by cachedTop ascending.
    // we can't sort the items array itself because item indexes must persist.

    var a = mapViaStream( streamViaArray( items ), function( item ) {
      return item.id;
    });

    a.sort( function( d, d_ ){
      var top = items[ d ].cachedTop,
          top_ = items[ d_ ].cachedTop;

      if ( top < top_ ) {
        return -1;
      } else if ( top > top_ ) {
        return 1;
      } else {
        return 0;
      }
    });

    // doubly-link the items

    var next = streamViaMap( streamViaArray( a ), function( id ) {
      return items[ id ];
    });

    var headItem = next();
    if (headItem) {
      headItem.previousItemIdentifier = null;  // aesthetics
      var curr = next();
      if (curr) {
        var prev = headItem;
        do {
          prev.twoWayJoinToNext( curr );
          prev = curr;
          curr = next();
        } while (curr);
        prev.nextItemIdentifier = null;  // aesthetics
      }
    }

    if (headItem) {
      self.identifierOfHeadItem = headItem.id;
      return ACHIEVED;
    } else {
      return error( "zero items?" );
    }
  } // __sortAndLinkItems

  function __describeItemMethod() {
    return "(" + this.id + ":" + this.cachedTop + ")";
  }

  function __linkedListMethods( o, lookup ) {

    o.nextItem = function() {
      return lookup( this.nextItemIdentifier );
    };

    o.previousItem = function() {
      return lookup( this.previousItemIdentifier );
    };

    o.twoWayJoinToAnyPrevious = function( prv ) {
      if (prv) {
        prv.twoWayJoinToNext( this );
      } else {
        this.previousItemIdentifier = null;
      }
    };

    o.twoWayJoinToAnyNext = function( nxt ) {
      if (nxt) {
        this.twoWayJoinToNext( nxt );
      } else {
        this.nextItemIdentifier = null;
      }
    };

    o.twoWayJoinToNext = function( item ) {
      item.previousItemIdentifier = this.id;
      this.nextItemIdentifier = item.id;
    };
  };

  // # support - "streams": null always indicates the end of the stream

  function mapViaStream( next, f ) {

    var a = [];
    var next_ = streamViaMap( next, f );
    var curr = next_();
    while ( null !== curr ) {
      a.push( curr );
      curr = next_();
    }
    return a;
  }

  function streamViaMap( next, f ) {

    return function() {
      var curr = next();
      if ( null === curr ) {
        return null;
      } else {
        return f( curr );
      }
    };
  }

  function streamViaArray( a ) {

    var lastIndex = a.length - 1;
    var d = -1;

    return function() {
      if ( lastIndex == d ) {
        return null;
      } else {
        d += 1;
        return a[ d ];
      }
    };
  }

  // # ~

  function error( msg ) {
    console.log( msg );
    return false;
  }
}
