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

  having said that, we chain ourselves lightly to a couple of them..


  # requirements

    • some particular jQuery version (but we do nothing fancy)
    • some particluar GSAP


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

    • todo: options for display
    • [ see 1 other TO-DO's below (indicated with "todo" in all caps) ]

  */

 /* # constants - credit is due: the starting points for most of the below
      values (most of which govern appearance (e.g animation)) were from
      "OSUblake"'s codepen example: http://codepen.io/osublake/pen/RNLdpz
      as needed we could turn them into options.
 */

  var __shadow2 = "0 6px 10px 0 rgba(0, 0, 0, 0.3), 0 2px 2px 0 rgba(0, 0, 0, 0.2)";

  // ## cheeky names for amounts of time

  var __moment = 0.2;
  var waltz = 0.35;

 /*
    # section 1 - detecting when a drag session should start

    a "drag session" can result in multiple re-orderings, as the user drags
    the moving tile up and down. the drag session ends "on release", not
    "on drag end" - we want to know that a release happened even if the
    "moving tile" wasn't moved at all.

    there is no state to maintain in between drag sessions - after tiles
    go thru their final reordering for the drag session (or even when no
    re-ordering occurred), any permanent changes are reflected in the DOM
    (perhaps only in the CSS properties). this makes implementation easier,
    at the cost of some redundant processing at the beginning of each drag
    session.


    ## concepts introduced

    • "drag session"

    • "tile": they "physical" dom element that can be moved (or a jQuery
              selection around same.)

    • "moving tile": the tile being dragged by the user. (note that other
                     tiles may move during a drag session as a response to
                     a re-ordering. we call these "displaced tiles".)

    • "dispalced tiles": see above. depending on context, does or does not
                         include the "moving tile".


    ## coding conventions introduced

    • variables & functions that exist only for readability (and not for re-
      use per se) have names with one and two leading underscores respectively.

    • we are commenting this module more heavily than usual for reasons.

 */

  $( '.scrubber', listElem ).mousedown( function() {

    var scrubber = $( this );
    var el = __findParentTileOfScrubber( scrubber );
    if ( el ) {
      __maybeStartDragSession( el, scrubber );
    }
  });

  function __findParentTileOfScrubber( current ) {

    // find the tile element as a parent of the scrubber element. we allow
    // that the "scrubber" and "tile" could be the same element.

    do {
      if ( current.hasClass( 'tile' ) ) {
        var found = current;
        break;
      }
      current = current.parent();

    } while ( current.length );

    if ( found ) {
      return found;
    } else {
      return error( "parent tile of scrubber not found (no \"tile\" class)" );
    }
  }

  function __maybeStartDragSession( movingTile, scrubber ) {

    var drg = Draggable.get( movingTile );
    if ( drg ) {
      error( "drag session already occuring for this tile? ignoring touch." );
    } else {
      __startDragSession( movingTile, scrubber );
    }
  }

 /* # section 2 - starting a drag session and indexing the itemz

    somewhat hackily, although it is the scrubber we use to detect the touch,
    we send the whole tile to Draggable so that the whole tile moves; even
    though conceptually we pretend it is only the scrubber we are dragging.

    ## concepts

    • "waypoint" - the drag event data is always expressed to us in terms
                   of how far up or down it has moved since the drag started
      (which was 0). when a subsequent re-ordering session happens in the
      same drag session, we need to make a note of this value so that we can
      have our drag (up or down) value be in terms of distance moved since
      this re-ordering session started, not in terms of since when the drag
      started.

    ## coding conventions introduced

    • we add a *trailing* underscore to a variable to differentiate it from
      another otherwise same-named variable in a nearby scope.
  */

  function __startDragSession( movingTile, scrubber ) {

    Draggable.create( movingTile, {
      bounds: listElem,
      onDrag: __onDrag,
      onRelease: __onRelease,
      zIndexBoost: false
    });

    // ## local "globals"

    var delta;  // how far up or down we've moved since last waypoint
    var head;
    var items;
    var lastWaypoint = 0;  // relativize the drag to the last reordering

    console.log("waypoint starts at " + lastWaypoint);

    var movingItem;
    var onMovedUpfromLastWaypoint, onMovedDownFromLastWaypoint;

    // ##

    __indexItems();
    // debuggingReport( 'at start: ' );
    reinitMovementHandlers();

    function __onDrag() {

      delta = this.y - lastWaypoint;

      if ( 0 > delta ) {
        onMovedUpfromLastWaypoint();
      } else if ( 0 < delta ) {
        onMovedDownFromLastWaypoint();
      }
      // else back to the point of origin for this waypoint, nothing to do.
    }

    function __onRelease() {  // not onDragEnd

      this.kill();  // for now we create a new draggable for every session.

      var item = movingItem;

      prepare_relative_Y_delta( item );

      var _tw = new TweenLite( item.element(), __moment, {  // OSUblake

        autoAlpha: 1, // 0.75,
        boxShadow: 'none', // __shadow2,
        paused: true,
        scale : 1,  //0.95,
        x: 0,
        y: item.relative_Y_delta
        // zIndex : "+=1000"
      });

      item.adoptAndPlayAsTimeline( _tw );
    }

    function __indexItems() {

      // (we store values that we consider to be "immutable" (in some regard)
      //  separate from mutable, in case we decide to preserve some of these
      //  calculations in between drag sessions;)

      items = [];
      window.ITEMS = items;

      var mutables = items;
      var immutables = [];

      var moving_DOM_element = movingTile[ 0 ];
      var next = streamViaArray( listElem.children() );
      var tile_DOM_element;

      var itemPrototype = {

        element: function() {
          return immutables[ this.id ].element;
        },

        height: function() {
          return immutables[ this.id ].height;
        },

        nextItem: function() {
          return itemAt( this.nextItemIdentifier );
        },

        previousItem: function() {
          return itemAt( this.previousItemIdentifier );
        },

        radius: function() {
          return immutables[ this.id ].radius;
        },

        verticalCenter: function() {
          return this.cachedTop + immutables[ this.id ].radius;
        }
      };

      Object.setPrototypeOf( itemPrototype, AnimationMethods );

      function itemAt( id ) {
        if ( null == id ) {
          return null;
        } else {
          return mutables[ id ];
        }
      }

      var d = beginItem();  // make the head node
      head = mutables[ d ];
      head.cachedTop = -1;  // hacky way to get this to end up at top
      head.nextItem = function() {
        return mutables[ head.nextItemIdentifier ];
      }
      Object.setPrototypeOf( head, itemPrototype );

      while ( tile_DOM_element = next() ) {

        if ( moving_DOM_element == tile_DOM_element ) {
          __addMovingItem();
          break;
        } else {
          addNonMovingItem();
        }
      }
      while ( tile_DOM_element = next() ) {
        addNonMovingItem();
      }

      function __addMovingItem() {

        var d = beginItem();
        immutables[ d ].element = movingTile;
        movingItem = mutables[ d ];
        finishItem( d );
        mutables[ d ].scrubberVertCenter = __calculateScrubberVertCenter();
      }

      function addNonMovingItem() {

        var d = beginItem();
        immutables[ d ].element = $( tile_DOM_element );
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

      __sortItems();
    }  // __indexItems

    function __calculateScrubberVertCenter() {

      // WARNING - what "top" means is very CSS dependant!

      var _localTop = scrubber.position().top - movingItem.cachedTop;
      var _ht = scrubber.height();
      return _localTop + ( _ht / 2 );
    }

    function __sortItems() {

      var a = [];
      var item;
      var next = streamViaArray( items );

      while ( item = next() ) {
        a.push( item.id );
      }

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

      // make the item values be a double linked list

      switch( a.length ) {
        case 0 : break;  // never
        case 1 : break;  // empty
        default:

          next = streamViaArray( a );

          var d = next();
          var prev = null;

          do {

            item = items[ d ];
            item.previousItemIdentifier = prev;

            prev = d;
            d = next();
            item.nextItemIdentifier = d;

          } while ( null != d );
      }
    } // __startDragSession

   /* # section 3 - detecting & repsonding to threshold breaches.

      imagine that the vertical center of the scrubber forms an imaginary
      horizontal line. (we will call this the "cursor".) then imagine that
      any above and below tiles to the tile being moved also have imaginary
      horizonal lines thru their vertical centers (that we will call
      "thresholds"). when the cursor "breaches" (hits or passes) a threshold,
      this is what triggers a re-ordering.

      ## concepts

      • "breach"
      • "cursor"
      • "gutter" - the distance between two adjacent tiles..
      • "radius" - an abuse of the term. is simply half of a vertical height.
      • "threshold"
   */

    function onBreach( isUpperThreshold ) {

     /* assume to know nothing about how a breach was detected. we must:

        • determine all the to-be "displaced tiles"
        • mutate the linked-listiness for those itemz (incl. moving tile)
        • mutate the tops for those itemz (incl. moving tile)
        • change the "waypoint"
        • create then effect an animation timeline for same.
      */

      var next = __buildStreamOfDisplacedItems( isUpperThreshold );

      // we will always *append* the moving piece to the above streams.

      var next_ = function() {
        var x = next();
        if (x) {
          return x;
        } else {
          next_ = function() {};
          return movingItem;
        }
      };

      function next__() {
        return next_();
      }

      var prevTop = movingItem.cachedTop;

      if ( isUpperThreshold ) {
        var displaced = __displaceWhenMovedUpwards( next__ );
      } else {
        var displaced = __displaceWhenMovedDownwards( next__ );
      }

      var _x = lastWaypoint;

      lastWaypoint += movingItem.cachedTop - prevTop;
      console.log("change waypoint from " + _x + " to " + lastWaypoint );

      // debuggingReport( 'wahoo: ', ' (wp: '+lastWaypoint+')' );

      reinitMovementHandlers();

      // an event would go here

      __animateDisplacement( displaced );
    }

    function __buildStreamOfDisplacedItems( isUpperThreshold ) {

      // (up) crawl up each next tile, and check if its vertical center is
      // below the "cursor". when you find one above the cursor, you're done.

      // (down) crawl down each next tile, and check if its vertical center
      // is above the "cursor". when you find one that is below, you're done.

      var _origScrubberVertCenter =
        movingItem.cachedTop + movingItem.scrubberVertCenter;

      var cursor = _origScrubberVertCenter + delta;

      var curr = movingItem;

      if ( isUpperThreshold ) {
        return function() {
          curr = curr.previousItem();
          if ( null != curr.previousItemIdentifier ) {
            if ( cursor <= curr.verticalCenter() ) {
              return curr;
            }
          }
        };
      } else {
        return function() {
          curr = curr.nextItem();
          if (curr) {
            if ( cursor >= curr.verticalCenter() ) {
              return curr;
            }
          }
        };
      }
    }

    function reinitMovementHandlers() {

      var prevItem = movingItem.previousItem();
      var nextItem = movingItem.nextItem();

      if ( null == prevItem.previousItemIdentifier ) {   // is head
        onMovedUpfromLastWaypoint = function(){
          console.log('uu');
        };
      } else {
        onMovedUpfromLastWaypoint = threshF( true );
      }

      if ( nextItem ) {
        onMovedDownFromLastWaypoint = threshF( false );
      } else {
        onMovedDownFromLastWaypoint = function(){
          console.log('dd');
        };
      }

      function threshF( isUpperThreshold ) {

       /* we may determine when the upper threshold is breached in this way:
          take the distance between the vertical center of the scrubber and
          the vertical center of the above tile. when the distance the tile
          has moved upwards is greater than the above distance, the breach
          has occurred.

          in more detail (and for upwards), take the sum of:
            • how far down the scrubber's vert. center is from the tile top
            • the length of the "gutter"
            • half the height of the upper tile

          if the amount we have moved exceeds that length, we have breached.

          we don't need to deal with gutters at all if we simply work from
          the tops of the two tiles, and "radiuses".

          to make the equivalent calculation downwards there will be slight
          variations in the arithmetic due to the coordinate system and the
          fact that the shape of tiles and their scrubbers is not vertically
          symmetrical.
       */

        if ( isUpperThreshold ) {

          var __tileJump = movingItem.cachedTop - prevItem.cachedTop;
          var __upperCenterToMovingTop = __tileJump - prevItem.radius();

          var upperDeltaThreshold = -1 * (
            __upperCenterToMovingTop + movingItem.scrubberVertCenter );

          console.log( "new upper threshold: " + upperDeltaThreshold );

          return function() {
            if ( delta < upperDeltaThreshold ) {
              onBreach( isUpperThreshold );
            } else {
              console.log( "delta: " + delta );
            }
          }
        } else {

          var __tileJump = nextItem.cachedTop - movingItem.cachedTop;

          var lowerDeltaThreshold = __tileJump -
            movingItem.scrubberVertCenter +
              nextItem.radius();  // (i had to draw it)

          console.log( "new lower threshold: " + lowerDeltaThreshold );

          return function() {
            if ( delta > lowerDeltaThreshold ) {
              onBreach( isUpperThreshold );
            } else {
              console.log( "delta: " + delta );
            }
          }
        }
      }
    }

    function __animateDisplacement( displacedItems ) {

      var next = streamViaArray( displacedItems );
      var item, tl;

      while ( item = next() ) {

        prepare_relative_Y_delta( item );

        var _tw = new TweenLite( item.element(), waltz, {
          paused: true,
          y: item.relative_Y_delta
          // keep zIndex at plus 1000 during the slide into place
        });

        item.adoptAndPlayAsTimeline( _tw );
      }
    }

    function prepare_relative_Y_delta( item ) {

     /*
        synopsis: mutate the item in two ways: 1) stop any existing animation
        2) set a property that expresses the Y delta.

        we don't love the fact that we resort to the (expensive?) call to
        jQuery's `position()` method for each displaced tile every time a
        displacement is effected (OK maybe that's not so often) but here's
        the issue (TODO):

        on first pageload we can can cache this first `top` value we get by
        this means, and then during displacement calculate a new top and send
        *the difference* in to the Y value of a tween. this works OK. the
        problem begins once we have any existing transformation on the tile
        DOM element: jQuery takes this into account when calculating
        position; but if we tell the tween the new Y to go to, it will
        clobber this old transform, causing the tile to jump.

        using relative values for the transform's Y is a good fit, then,
        but the problem then occurs that we can very easily be in the middle
        of one animation when we need the tile to turn around and go back,
        for example. (that is, our `cachedTop` is unreliable for this
        purpose.) our solution to this for now is to use jQuery to calculate
        the top again..
      */

      // stop moving so we can get a reliable reading on the top
      item.stopAnyExistingTimeline();

      // the delta between the desired top and the actual top is the amount
      // of *relative* change we want to instill in the transform.

      var _actual = item.element().position().top;
      var delta = item.cachedTop - _actual;

      if ( 0 > delta ) {
        var s = '-=' + ( -1 * delta ) + 'px';
      } else {
        var s = '+=' + ( delta ) + 'px';
      }

      console.log( "" + item.id + ": " + s );
      item.relative_Y_delta = s;
    }

    function absolutePixels( flot ) {

      return flot;
      // or: return '' + flot + 'px';
    }

   /* # section 4 - this
    *
      (this section got messier after the rewrite, because linked lists)
    */

    function __displaceWhenMovedUpwards( origNext ) {

      // (up) each displaced tile, subtract (its height plus some gutter)
      // from some Y to get its top.

      var gutters = [], items_ = [];
      __calculateUpwardGutters( gutters, items_, origNext );
      var next = streamViaArray( items_ );
      var nextGutter = streamViaArray( gutters );

      var below = next();

      below.nextItemIdentifier = movingItem.nextItemIdentifier;
      var belowest = movingItem.nextItem();
      if (belowest) {
        belowest.previousItemIdentifier = below.id;
      }

      var above = next();

      var some_Y = movingItem.cachedTop + movingItem.height() - below.height();
      below.cachedTop = some_Y

      do {

        var _gutter = nextGutter();

        some_Y = some_Y - _gutter - above.height();
        above.cachedTop = some_Y;

        var topmostIdentifier = below.previousItemIdentifier;
        below.previousItemIdentifier = above.id;
        above.nextItemIdentifier = below.id;

        var x = next();
        if ( ! x ) { break; }

        below = above;
        above = x;

      } while ( true );

      above.previousItemIdentifier = topmostIdentifier;
      if ( null != topmostIdentifier) {
        items[ topmostIdentifier ].nextItemIdentifier = above.id;
      }

      items_.pop();
      return items_;
    }

    function __displaceWhenMovedDownwards( origNext ) {

      // (down) the first displaced tile always "takes over" the top value
      // from the moving tile. note the former's height. each next tile in
      // the stream will be some Y plus the previous height plus some gutter.

      var gutters = [], items_ = [];
      __calculateDownwardGutters( gutters, items_, origNext );
      var next = streamViaArray( items_ );
      var nextGutter = streamViaArray( gutters );

      var curr = next();
      var some_Y = movingItem.cachedTop;
      curr.cachedTop = some_Y;

      curr.previousItemIdentifier = movingItem.previousItemIdentifier;

      var prev = movingItem.previousItem();
      if (prev) {  // might be head node, that is OK
        prev.nextItemIdentifier = curr.id;
      }

      prev = curr;
      curr = next();

      do {

        some_Y = some_Y + prev.height() + nextGutter();
        curr.cachedTop = some_Y;

        var lastId = prev.nextItemIdentifier;

        prev.nextItemIdentifier = curr.id;
        curr.previousItemIdentifier = prev.id;

        var x = next();
        if ( ! x ) { break };

        prev = curr;
        curr = x;

      } while ( true );

      curr.nextItemIdentifier = lastId;
      if ( null != lastId) {
        items[ lastId ].previousItemIdentifier = curr.id;
      }

      items_.pop();
      return items_;
    }

    function __calculateUpwardGutters( gutters, items_, next ) {

      return calculateGutters( streamViaArrayReversed, gutters, items_, next );

    }

    function __calculateDownwardGutters( gutters, items_, next ) {

      return calculateGutters( streamViaArray, gutters, items_, next );
    }

    function calculateGutters( streamF, gutters, items_, origNext ) {

      var a = [];
      var x;
      while ( x = origNext() ) {
        a.push( x );
        items_.push( x );
      }
      a.splice( 0, 0, a.pop() ); // egads

      var next = streamF( a );
      var prev = next();
      var curr = next();
      do {

        var _gutter = curr.cachedTop - prev.cachedTop - prev.height();
        gutters.push( _gutter );

        var x = next();
        if ( null == x ) { break; }
        prev = curr;
        curr = x;
      } while( true );
    }

    function debuggingReport( msg, msg_ ) {

      var a = [];
      var x = head;
      while ( x = x.nextItem() ) {
        a.push( "" + x.id + "("+ Math.ceil( x.cachedTop ) +")" );
      }
      console.log( "" + ( msg || '') + "(" + a.join(', ')+")" + ( msg_ || '' ));
    }
  }  // __startDragSession

  AnimationMethods = {

    stopAnyExistingTimeline: function() {

      prev_tw = this.timeline;
      if (prev_tw) {
        console.log("PAUSING IN PROGRESS animaion..");
        prev_tw.pause();  // there is no stop for tweens..
        this.timeline = null;
      }
    },

    adoptAndPlayAsTimeline: function( tl ) {

      this.timeline = tl;

      var me = this;
      tl.eventCallback( "onComplete", function() {
        me.timeline = null;
      });

      tl.play();
    }
  };

  // # support

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

  function streamViaArrayReversed( a ) {

    var d = a.length;

    return function() {
      if ( d ) {
        d -= 1;
        return a[ d ];
      } else {
        return null;
      }
    };
  }

  // ## xx

  function error( msg ) {
    console.log( msg );
    return false;
  }
}
