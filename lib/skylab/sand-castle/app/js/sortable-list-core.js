function SkylabSortableListCore( $listElem ) {

/*
  # synopsis

  this is the "core" implementation of a sortable list, intended to look
  and feel like the sorting interface for iPhone's "reminders" app (at least,
  its look at feel at this moment). (this design is probably elsewhere too.)

  we say "core" because this code itself is not packaged as e.g. an angular
  directive or jQuery plugin; but rather it is intended to serve as the
  "backend" for such plugins as they are created. this decoupling is by
  design, so that we are not anchored to any one framework's ecosystem, but
  rather so that we can be buoyed by all of them; while being insulated from
  their occasionally capricous API's.

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

      * re-ordering does not mutate the DOM with respect to elements
        and their ordering, it only mutates the CSS "top" property.

    • implementation style:
      * jquery selectors are not littered throughout the code.
      * adds only one constant to the global namespace.
      * no prototypes, only closures.


  # TODO's / wishlist / known issues

    • todo: options for display
    • tiny X-axis jolt when the moving tile snaps into its final place ..


  # implementation & style

  local idioms: "tile" refers to the DOM element or jQuery selector of same.
  "item" refers to our internal datastructure JS object about same.
  (or if you prefer: the former is view-ish, the latter is the model-esque.)

  coding style synopsis: variables and function that exist only for
  readability (and not for re-use) have names with one and two leading
  underscores respectively.

  we add a *trailing* underscore to a variable to differentiate it from
  another otherwise same-named variable in a nearby scope.

  we commented more heavily than usual for reasons.
*/

 /* ~ constants - credit is due: the starting points for most of the below
      values (most of which govern appearance (e.g animation)) were from
      "OSUblake"'s codepen example: http://codepen.io/osublake/pen/RNLdpz
      as needed we could turn them into options.
 */

  var gutter = 7; // if we wanted to be crazy we could derive this from etc.
  var __moment = 0.2;
  var waltz = 0.35;
  var __shadow2 = "0 6px 10px 0 rgba(0, 0, 0, 0.3), 0 2px 2px 0 rgba(0, 0, 0, 0.2)";

  // ~ section: initting a re-ordering session:
  //            this entire document impelements a re-ordering session. all
  //            such sessions begin by touching a scrubber..

  var __scrubbers = $( '.scrubber', $listElem );

  __scrubbers.mousedown( function(){

    var scrubber = $( this );
    var movingTile = scrubber.parent();
    var got = Draggable.get( movingTile );

    if ( got ) {
      console.log( "drag session already ocurring for this tile? - ignoring mousedown." );
      // got.kill();
    } else {
      __startDrag( movingTile, scrubber );
    }
  });

  function __startDrag( movingTile, scrubber ) {

   /*
      at mousedown/touch of one of the the "scrubber" rectangles:
       • determine any top threshold (vertical center of any tile above)
       • determine any bottom threshold (ditto)
       • somehow memoize something like the top of the moving tile ..
    */

    var items = __buildSortedItems();

    __accentuateMovingTile();  // after above - preserve original top

    var indexOfMovingItem = __indexOfMovingItem();

    var whenMovedUp, whenMovedDown;  // set in next statement
    recalculateThresholds();

    var ready = true;  // this may just be a sanity check..
                       // ignore new incoming events when we are "busy"..

    var drg = Draggable.create( movingTile, {
      bounds: list,
      onDrag: __onDrag,
      onRelease: __onRelease,
      zIndexBoost: false
    })[ 0 ];

    var lastWaypoint = 0;  // "up" or "down" is relative to the last waypoint

    // ~ section - wiring & animating the start and end of drag

    function __onDrag() {

      var delta = this.y - lastWaypoint;

      if ( 0 > delta ) {
        whenMovedUp();
      } else if ( 0 < delta ) {
        whenMovedDown();
      } else {
        // back to zero. ignored for now..
      }
    }

    function __accentuateMovingTile() {

      TweenLite.to( movingTile, __moment, {  // OSUblake
        autoAlpha : 0.75,
        boxShadow : __shadow2,
        scale : 0.95,
        zIndex : "+=1000"
      });
    }

    function __onRelease() {  // not onDragEnd

      this.kill();  // always end the drag session on drag end for sanity.

      var item = items[ indexOfMovingItem ],
          elem = item.element;

      items = null;  // sanity.

      var tl = initFreshTimeline( item );

      tl.to( elem, waltz, {
        autoAlpha : 1,
        boxShadow : 'none',
        scale: 1,
        top: item.volatileTop,
        x: 0,  // without this, see
        y: 0,
        // keep zIndex at plus 1000 during the slide into place
      });

      tl.eventCallback( "onComplete", function() {

        elem.css({ zIndex: 0 });
        // put it back only when done moving it into place
      });

      tl.play();
    }

   /* section: the sorted items array

      result is an array of our internal "item" objects, sorted by how
      high up on the screen the tile is, highest (i.e lowest "top") first.

      for our own sanity, this structure is re-built from scratch for each
      drag session: there is no long-running state. the order of the items
      is entirely isomorphic with the "top" CSS values of each tile. we use
      the DOM as the "model" in this regard (for now).

      by this definition: the threshold is reached when the vertical center
      of the scrubber of the moving tile passes the vertical center of the
      neighboring above or below tile. (ergo it "takes longer" to switch
      places with a taller tile.) GSAP reports how far the tile has moved
      (up or down) since the beginning of the drag. we will add that number
      to this number to find the "imaginary cursor" that we use to determine
      when the above or below threshold is reached.
   */

    function __buildSortedItems() {

      var items = [];

      var moving_DOM_element = movingTile[ 0 ];

      movingTile.parent().children().each(function(){  // or $(".tile" ..) etc

        var item = {};

        if ( moving_DOM_element === this ) {  // (please work across browsers)

          item.calculateVolatileScrubberCenter = function() {

            return( item.volatileTop +
              // (the scrubber's proportions may change w/ animation)
              scrubber.position().top + ( scrubber.height() / 2 ) );
          }

          item.calculateVolatileTop = function(){
            return item.element.position().top;
          }

          var elem = movingTile;

          item.element = elem;
          item.height = elem.height();
          item.isTheMovingItem = true

          item.volatileTop = item.calculateVolatileTop();

          item.scrubberCenterAtStartOfDrag =
            item.calculateVolatileScrubberCenter()

        } else {

          var elem = $( this );

          var height = elem.height();
          var radius = height / 2;

          item.initVolatileCenter = function() {
            item.volatileCenter = item.volatileTop + radius;
          };

          item.element = elem;
          item.height = height;
          item.isTheMovingItem = false;
          item.volatileTop = elem.position().top;

          item.initVolatileCenter();
        }

        items.push( item );
      });

      items.sort( function( item_A, item_B ){
        if ( item_A.volatileTop < item_B.volatileTop ) {
          return -1;
        } else if ( item_A.volatileTop > item_B.volatileTop ) {
          return 1;
        } else {
          return 0;
        }
      });

      return items;
    }

    function __indexOfMovingItem() {

      var i = items.length;
      var result = null;
      while ( i-- ) {
        if (items[ i ].isTheMovingItem) {
          result = i;
          break;
        }
      }
      return result;
    }

   /* ~ section: handling breached thresholds

      if the moved tile breached an upper (and not lower) threshold, any
      tiles that used to sit below the moved tile will certainly remain
      unmoved. the complement (where up is down, etc) is also true.

      (if it moved up) take *the* (not any) above neighbor of the moving
      tile, and then each (any) additional tile above that one whose vertical
      center is below the scrubber's last known vertical center. the stream
      of tiles formed by this process is the stream of displaced tiles.

      (if it moved down, the stream of displaced tiles is determined in the
      same manner but with the directions switched.)

        • use arithemtic to deterimine each new position of each displaced
          tile in stream order, taking into account something like the top
          and height of each previous tile and a gutter (i.e full margin)
          constant.

        • this calculation will also be done for the moving tile (which is
          always the last item in the stream); but note that this new
          hypothetical position will not be effected during the drag, but
          only at the drop as a sort of "snap to".

        • the arithmetic may sound overly complicated, but remember it
          is necessary to take into account the non-uniform heights of
          the different tiles as they re-arrange.
    */

    function __whenPassedUpperThreshold() {
      whenPassedThreshold( true );
    }

    function __whenPassedLowerThreshold() {
      whenPassedThreshold( false );
    }

    function whenPassedThreshold( movedUp ) {

      ready = false;  // lockout (todo - may not be necessary)

      var _indexes = __calculateDisplacement( movedUp );
      __executeDisplacement( _indexes, movedUp );

      ready = true; // while the above animation is running,
        // we can accomodate new events
    }

    function __calculateDisplacement( movedUp ) {

      var nextIndex = __buildIndexStream( movedUp );

      var d = nextIndex();
      var indexesOfDisplacedItems = [];

      var movingItem = items[ indexOfMovingItem ]

      if ( movedUp ) {
       /*
          when moved up, imagine that the displaced tiles are a series of
          objects of non-uniform height being stacked on top of each other,
          but remember the coordinate system has Y growing downwards.

          when moved up, to determine the first moved-over tile's new top
          derive an imaginary lower tile top and subtract from that the
          height of the moved-over tile. this imaginary lower tile top is
          derived from the moving tile's top and height.

          arrive at each next tile's top by subtracting this current tile's
          height from each previous top.
        */

        var top = movingItem.volatileTop + movingItem.height + gutter;

        var f = function( item_ ) {
          var _top_ = top - item_.height - gutter;
          top = _top_;
          return top;
        }

      } else {
       /*
          when moved down, imagine that you are hanging the first moved-over
          tile from the ceiling, and affixing each next moved over tile to
          the bottom of the previous one.

          when moved down, to determine the first moved-over tile's new top
          it is always simply the top of the moving tile (before it was
          picked up). each next top is derived from each previous top plus
          the height of that previous item.
        */

        var f = function( item_ ) {

          var prevItem = item_;
          var top = movingItem.volatileTop;

          f = function( item__ ) {
            var _top_ = top + prevItem.height + gutter;
            prevItem = item__;
            top = _top_;
            return top;
          }

          return top;
        }
      }

      do {
        indexesOfDisplacedItems.push( d );
        var item = items[ d ];
        item.bearingTop = f( item );
        d = nextIndex();
      } while ( null != d );

      return indexesOfDisplacedItems;
    }

    function __buildIndexStream( movedUp ) {

     /* result is a function that returns each next relevant item index.
        we have written the mirror image code below in "longhand" for
        readability at the expense of DRYness..
      */

      var scrubberCenter = items[ indexOfMovingItem ].
        calculateVolatileScrubberCenter();

      var nextIndex;
      if ( movedUp ) {
        nextIndex = function() {
          var d = indexOfMovingItem - 1;
          var last = 0;
          nextIndex = function() {
            if ( last < d ) {
              d--;
            }
            if ( scrubberCenter <= items[ d ].volatileCenter ) {
              return d;
            } else {
              nextIndex = null;
              return indexOfMovingItem;
            }
          };
          return d;
        };
      } else {
        nextIndex = function() {
          var d = indexOfMovingItem + 1;
          var last = items.length - 1;
          nextIndex = function() {
            if ( last > d ) {
              d++;
            }
            if ( scrubberCenter >= items[ d ].volatileCenter ) {
              return d;
            } else {
              nextIndex = null;
              return indexOfMovingItem;
            }
          };
          return d;
        };
      }

      return( function() {
        if ( nextIndex ) {
          return nextIndex();
        } else {
          return null;
        }
      });
    }

    function __executeDisplacement( indexes, movedUp ) {

     /* • tell each displaced item that it is already in its new location
          (because for the purposes of threshold calculations from this point
          forward, it is).

        • effect the animation that actually moves each tile to its new
          location. each item will have its own "timeline" that can be stopped
          if the item's bearings change before the animation is complete.

        • in the items array reposition each displaced item (including moving)

        • re-calculate the thresholds
      */

      var d_ = indexes.length - 1;  // an index into the indexes array

      // (`d_` and `indexOfMovingItem` are the same offset here.)

      var movingItem = items[ indexOfMovingItem ];  // the moving item

      lastWaypoint += ( movingItem.bearingTop - movingItem.volatileTop );
        // calcuate whether this is a move up or down based not on the
        // net move relative to the start of the drag but relative to that
        // point as it was at the last displacement waypoint.

      var replaceThisItem = indexOfMovingItem;
      items[ replaceThisItem ] = null;  // let this float for a minute..

      effectNewTop( movingItem );

      // for the one or more remaining items in the list:

      do {

        d_--;  // there is always at least one

        var d = indexes[ d_ ];
        var item = items[ d ];
        items[ d ] = null;  // go it away for a second..

        items[ replaceThisItem ] = item;
        replaceThisItem = d;

        effectNewTop( item );
        item.initVolatileCenter();
        __initAndPlayFreshTimelineForMoveToBearing( item );

      } while ( d_ );  // stop when you just did 0

      items[ replaceThisItem ] = movingItem;
      indexOfMovingItem = replaceThisItem;

      recalculateThresholds();  // recalculate these now that things have changed
    }

    function effectNewTop( item ) {
      item.volatileTop = item.bearingTop;
      item.bearingTop = null;
    }

    /* ~ section - bearings and animation

      a "bearing" is simply the particular destination Y-value that any
      one displaced tile is supposed to end up at.

      this bearing gives rise to one animation with a hypothetically fixed
      duration. if the bearing changes while the animation is still
      taking place, you have at least two choices:

      one, you could always wait for every animation to complete before
      starting each new such animation for each such new bearing that
      occurs while animation is still happening. the effect of this is
      undesirable: the pending queue of animation grows and grows and takes
      time to "catch up" to the intended state, giving the appearance of
      lag.

      for more responsiveness, what we want in such cases is to "cancel"
      the in-progress animation and start over with a tween that moves the
      tile to the latest known correct bearing. (imagine a human driver of
      a car being given a series of ever-changing destinations. do you want
      the driver to go to each given destination in order, or do you want
      the driver only ever to be heading towards whatever the latest
      destination is?)

      the way we detect whether or not there is an active animation for the
      item is by associating every timeline object with its item and then
      deleting that timeline when the animation completes. in such cases
      where the bearing changes mid-animation, we merely stop the in-
      progress animation. the new tween we make should take care of the
      rest. (note that in such bearing changes, the tile may have more
      distance to cover than usual in the same amount of time, giving rise
      to the tile moving faster.)
    */

    function __initAndPlayFreshTimelineForMoveToBearing( item ) {

      var tl = initFreshTimeline( item );

      tl.to(
        item.element,
        waltz,
        { top: item.volatileTop } );

      tl.play();
    }

    function initFreshTimeline( item ) {

      var tl = item.timeline;

      if ( tl ) {
        tl.stop();
      }

      tl = new TimelineLite();

      item.timeline = tl;

      tl.eventCallback( "onComplete", function() {
        item.timeline = null;
      });

      return tl;
    }

  /* section - "threshold theory" for this mechanism:

     let the vertical center of the scrubber of the moving tile act as
     our "imaginary cursor": for every possible moving tile of every
     possible list in every possible order of that list; there exists
     either zero, one or two "thresholds" whose breach by this imaginary
     cursor we will watch for. the occurrence of such a breach constitutes
     the sole means by which a re-ordering is triggered.

     any upper threshold is the vertical center of any immediately above
     tile of the moving tile (based on where it sat before we started
     moving it). likewise any lower threshold is any vertical center of
     any immediately below tile to where the moving tile used to sit.

     when the moving tile had been the top or bottom tile, there is no
     upper/lower threshold, and ergo a move up or down does nothing (all
     respectively) in such cases.

     the moving tile is both top *and* bottom tile IFF the list is one
     item long. in such cases there are no thresholds, ergo moving the
     tile will never do anything (except animate a circuitous journey).

     the subject does not concern itself with detecting the "tiles"
     (not tile) that are displaced by this move. although the set of
     displaced tiles certainly includes the moving tile and first tile
     it moved over, whether the moving tile has moved over any additional
     tiles by the time the displacement is calculated is outside of this
     scope. here we are only concerned with calculating thresholds and
     detecting their breach.
    */

    function recalculateThresholds() {

      var movingItem = items[ indexOfMovingItem ];

      if ( 0 == indexOfMovingItem ) {  // is top tile

        whenMovedUp = function(){};

      } else {

        var topThresholdDelta =
          items[ indexOfMovingItem - 1 ].volatileCenter -
            items[ indexOfMovingItem ].scrubberCenterAtStartOfDrag;

        whenMovedUp = function(){

          if ( ready && drg.y < topThresholdDelta ) {
            __whenPassedUpperThreshold();
          }
        }
      }

      if ( items.length - 1 == indexOfMovingItem ) {  // is bottom tile

        whenMovedDown = function(){};

      } else {

        var bottomThresholdDelta =
          items[ indexOfMovingItem + 1 ].volatileCenter -
            items[ indexOfMovingItem ].scrubberCenterAtStartOfDrag;

        whenMovedDown = function(){

          if ( ready && drg.y > bottomThresholdDelta ) {
            __whenPassedLowerThreshold();
          }
        }
      }
    }
  }
}
