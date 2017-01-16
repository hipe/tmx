module Skylab::Zerk::TestSupport

  module CLI::ExpectSectionMagneticsSupport__  # #[#sl-155]

  module CLI::Expect_Section_Magnetics  # :[#054.2]

    # the second ever in the #[#054] strain, this was the first ever
    # to parse a help screen with a state machine. the scope of the file
    # has been broadened to become general support for the siblings.

    # this is now painfully similiar to [#054.3] but for a very different purpose

    module CommonBranchUsageLineIndex_via_Line

      # parse a line like this:
      #
      #     "shipple dipple { homunculous | wiff-wub | zeep } !@#$"
      #
      # into a structure like this:
      #
      #     index.head  # => "shipple dipple "
      #     index.tail  # => " !@#$"
      #
      #     index.item_index  # =>
      #       { homunculous:  0,
      #         wiff_wub:     1,
      #         zeep:         2, }

      class << self
        def call line
          md = /\A(?<A>[^{]+)\{ (?<B>[^}]*) \}(?<C>[^{}]*)\z/.match line
          # ..
          CommonBranchUsageLine___.new( * md.captures )
        end
        alias_method :[], :call
      end  # >>

      class CommonBranchUsageLine___

        def initialize head, mid, tail
          @_item_index = :__item_index_initially
          @head = head ; @mid = mid ; @tail = tail
        end

        def item_index
          send @_item_index
        end

        def __item_index_initially
          h = {}
          @mid.split( ' | ' ).each_with_index do |s, d|
            h[ Normal_symbol_via_slug__[ s ] ] = d
          end
          @__item_index = h.freeze
          @_item_index = :__item_index_normally
          send @_item_index
        end

        def __item_index_normally
          @__item_index
        end

        attr_reader :head, :mid, :tail
      end
    end

    module CommonOperatorUsageLineIndex_via_Line

      # parse a line like this:
      #
      #     "foobie doobie ploobie [ -wiff-wang ..] [ -wib ..] [ -x ..] .."
      #
      # into a structure like this:
      #
      #     index.head  # => "foobie doobie ploobie "
      #
      #     index.item_index  # =>
      #       { wiff_wang: #<struct offset=0, had_ellipsis=true>,
      #         wib:       #<struct offset=1, had_ellipsis=false>,
      #         x:         #<struct offset=2, had_ellipsis=true> }
      #
      #     index.had_ellipsis  # => true

      class << self

        def call line

          md = %r(\A[^\[]+).match line
          _head = md[0]
          _tail = md.post_match

          s_a = _tail.split %r((?<=\])[ ])   # "[ -jif-jaf ..] [ -wib ..] [ -xx ..] .."
          if '..' == s_a.last  # DOT_DOT_
            had = true
            s_a.pop
          end
          h = {}
          rx = /\A\[ -(?<slug>[-a-z0-9]+) (?<el>\.\.)?\]\z/
          s_a.each_with_index do |s, d|
            md = rx.match s
            if md.offset(:el)[0]
              _had = true
            end
            _k = Normal_symbol_via_slug__[ md[:slug] ]
            h[ _k ] = Item___.new d, _had
          end
          CommonBranchUsageLine___.new had, h, _head
        end
        alias_method :[], :call
      end  # >>

      class CommonBranchUsageLine___

        def initialize had, h, head
          @had = had
          @head = head
          @item_index = h
        end

        attr_reader(
          :had_ellipsis,
          :head,
          :item_index,
        )
      end

      Item___ = ::Struct.new :offset, :had_ellipsis
    end

    class CommonItemsSection_via_LineStream < Common_::Actor::Monadic  # 1x

      # parse the help screens that are newest at the time of writing -
      # the only tricky thing we do here is that in effect we write the
      # grammar as it's being parsed - we don't know the tab stops until
      # a first line with description is read..

      def initialize st
        @line_stream = st
      end

      def execute

        st = remove_instance_variable :@line_stream
        # ..
        _scn = st.flush_to_polymorphic_stream
        _sm = __build_state_machine
        _memo = _sm.solve_into_against Memo___.new, _scn
        _memo.finish
      end

      def __build_state_machine

        o = Basic_[]::StateMachine.begin_definition

        o.add_state(
          :beginning,
          :can_transition_to, [
            :only_header_line,
          ],
        )

        o.add_state(
          :only_header_line, :entered_by_regex, %r(\A(?<header>[^:]+):\z),
          :on_entry, -> sm do
            sm.downstream.__receive_header_ sm.user_matchdata
            :first_item_line
          end,
        )

        _first_item_line_rx = %r(\A
          (?<margin>[ ]{2,})

          (?<moniker> (?:(?![ ]{2}).)+ )

          (?<spacer>[ ]{2,})

          (?<desc1>[^ ].*)
        $)x

        same = [
          :additional_desc_line,
          :blank_line,
          :nonfirst_item_line,
          :ending,
        ]

        use_additional_desc_rx = nil
        use_nonfirst_item_rx = nil
        nonfirst_item_indented_by_four_rx = nil

        setup_shop = -> md do
          setup_shop = nil

          beg, en = md.offset :spacer

          use_nonfirst_item_rx = %r(\A
            (?<column_one>.{#{ beg }})
            [ ]{2}
            (?<desc1>[^ ].*)
          $)x

          nonfirst_item_indented_by_four_rx = %r(\A
            (?<column_one>[ ]{#{ beg }})
            [ ]{2}
            (?<desc1>[ ]{4}[^ ].*)
          $)x

          use_additional_desc_rx = %r(\A
            [ ]{#{ en }}
            (?<desc>[^ ].*)
          $)x
        end

        o.add_state(
          :first_item_line, :entered_by_regex, _first_item_line_rx,
          :on_entry, -> sm do
            md = sm.user_matchdata
            setup_shop[ md ]
            sm.downstream._receive_column_one_and_desc_ md[:moniker], md[:desc1]
            NOTHING_
          end,
          :can_transition_to, same,
        )

        _additional_desc_rx = Matcher__.new do |s|
          use_additional_desc_rx.match s
        end

        o.add_state(
          :additional_desc_line, :entered_by_regex, _additional_desc_rx,
          :on_entry, -> sm do
            sm.downstream.__receive_additional_description_content_(
              sm.user_matchdata[:desc] )
            NOTHING_
          end,
          :can_transition_to, same,
        )

        o.add_state(
          :blank_line, :entered_by_regex, %r(\A$),
          :on_entry, -> _sm do
            # you could somehow "close" the item, but why?
            # separator lines are cosmetic and not guaranteed
            NOTHING_
          end,
          :can_transition_to, [
            :nonfirst_item_line,
            :ending,  # this happens only with a section followed by another section
          ],
        )

        _nonfirst_item_rx = Matcher__.new do |s|

          # pretty awful

          md = use_nonfirst_item_rx.match s
          if ! md
            md = nonfirst_item_indented_by_four_rx.match s
            if ! md
              self._YOU_MIGHT_WANT_TO_CHANGE_TACK
            end
          end
          md
        end

        o.add_state(
          :nonfirst_item_line, :entered_by_regex, _nonfirst_item_rx,
          :on_entry, -> sm do
            md = sm.user_matchdata
            sm.downstream._receive_column_one_and_desc_ md[:column_one], md[:desc1]
            NOTHING_
          end,
          :can_transition_to, same,
        )

        o.add_state(

          :ending,
          :entered_by, -> scn do
            if scn.no_unparsed_exists
              # any state that indicated this as a possible next
              # state may enter without barrier from this state
              :_trueish_
            else
              # (this sub-state might indicate that a parse error is about to happen..)
              UNABLE_
            end
          end,

          :on_entry, -> sm do
            sm.receive_end_of_solution  # you must declare that you have no next state
          end,
        )

        o.finish
      end

      # ==

      class Memo___

        def initialize
          @_h = {}
          @_items = []
          @_rcoad = :__receive_first_ever_coad
          @_rh = :__receive_header_once_ever
        end

        def __receive_header_ md
          send @_rh, md
        end

        def __receive_header_once_ever md
          remove_instance_variable :@_rh
          @__header_md = md ; nil
        end

        def _receive_column_one_and_desc_ col_A, desc
          send @_rcoad, col_A, desc
        end

        def __receive_first_ever_coad col_A, desc
          _init_item col_A, desc
          @_rcoad = :__receive_subsequent_coad ; nil
        end

        def __receive_subsequent_coad col_A, desc
          _swallow_item
          _init_item col_A, desc
        end

        def _init_item col_A, desc
          @_col_A = col_A ; @_desc_pieces = [ desc ] ; nil
        end

        def __receive_additional_description_content_ s
          @_desc_pieces.push s ; nil
        end

        def finish
          _swallow_item
          ItemSection___.new(
            remove_instance_variable( :@_h ),
            remove_instance_variable( :@__header_md ),
            remove_instance_variable( :@_items ),
          )
        end

        def _swallow_item

          moniker = remove_instance_variable( :@_col_A ).strip

          _md = %r(\A-*).match moniker

          _key = Key_via_moniker__[ _md.post_match ]

          _ary = remove_instance_variable :@_desc_pieces

          @_h[ _key ] = @_items.length
          @_items.push Item___.new _ary
          NIL
        end
      end

      # ==

      class ItemSection___

        def initialize h, md, a
          @item_offset_via_key = h
          @_header_md = md
          @items = a
        end

        def label_content
          @_header_md[ :header ]
        end

        def label_line
          @_header_md.string
        end

        attr_reader(
          :item_offset_via_key,
          :items,
        )
      end

      # ==

      class Item___

        def initialize s_a
          @desc_string_array = s_a
        end

        attr_reader(
          :desc_string_array,
        )
      end

      # ==
    end

    module SectionsOldSchool_via_LineStream

      # the second of five facilities, this is :[#054.2] of #[#054]
      # very short, very opaque, somewhat intriguing

      # #feature-island, not used, but #legacy-coverpoint-1:

      # we tried to use this for new work (another state machine in
      # this file) - although this was doing *something* (and apparently
      # working as advertised), it was not the parse we wanted. yes we
      # should probably archive it..

      class << self
        def call st
          Require_olschool_state_machine__[]
          Parse_sections___[ [], st ]
        end
        alias_method :[], :call
      end  # >>

      # ==
  Require_olschool_state_machine__ = Lazy_.call do
    # (we might need to build the below once per parse if ..)

    state_h = { }  # das state machine

    state = ::Struct.new :rx, :to

    #         name               regex         which can be followed by..

    state_h[ :initial ] = state[ nil,          [ :section, :desc ] ]
    state_h[ :desc    ] = state[ //,           [ :section, :normal ] ]
    state_h[ :normal  ] = state[ //,           [ :section, :normal ] ]
    state_h[ :section ] = state[ /\A[^:]+:\z/, [ :item, :normal ] ]
    state_h[ :item    ] = state[
                       /\A(?<ind> +)(?<hdr>((?!  ).)+)(?: {2,}(?<bdy>.+))?\z/,
                                      [ :subitem, :item, :section, :normal ] ]
    state_h[ :subitem ] = state[ nil, # (<- guess what will happen here)
                                      [ :subitem, :item, :section, :normal ] ]

    item_rx_h = ::Hash.new { |h, k| h[k] = /\A {#{ k },}(.+)\z/ }  # cache rx

    Parse_sections___ = -> sections, lines do
      stat = state_h[ :initial ]  # (var meaning change!!)
      section = line = nil
      push = -> { sections << ( section = Section___.new nil, [] )  }
      trigger_h = {
        desc:    -> { push[] ; section.lines << [ :line, line ] },
        section: -> { push[] ; section.header = line },
        normal:  -> {          section.lines << [ :line, line ] },
        item:    -> {          section.lines << [ :item, * $~.captures[1..-1]]
                               state_h[:subitem].rx =  # *NOTE* not #idempotent
                                 item_rx_h[ $~[:ind].length + 1 ] },
        subitem: -> {          section.lines << [ :item, nil, $~[1] ] }
      }
      while (( line = lines.gets ))
        line.chomp!
        name_i = stat.to.detect do |i|
          state_h[ i ].rx =~ line
        end
        trigger_h.fetch( name_i ).call
        stat = state_h.fetch name_i
      end
      sections
    end
    NIL
  end
      # ==

      # ==

      Section___ = ::Struct.new :header, :lines  # 1 of #[#054.A]

      # ==

    end  # end magnet
  end  # magnetics

  # (you're in support now)

    # ==

    Key_via_moniker__ = -> moniker do
      if CLEAN_RX___ =~ moniker
        Normal_symbol_via_slug__[ moniker ]
      else
        moniker
      end
    end

    Normal_symbol_via_slug__ = -> s do
      s.gsub( DASH_, UNDERSCORE_ ).intern
    end

    # ==

    class Matcher__ < ::Proc
      alias_method :match, :call
    end

    # ==

    CLEAN_RX___ = /\A[-a-z0-9]+\z/i

    # ==

  end  # support
end
