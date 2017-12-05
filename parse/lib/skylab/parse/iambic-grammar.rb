module Skylab::Parse

  class IambicGrammar < Common_::SimpleModel  # :[#006].

    # (three laws. would replace entity)

    # entity is at once too rigid, too over-abstracted, and too overwrought

    # -

      def initialize
        @_injections = []
        @_keyword_cache = {}
        yield self
        @_injections.freeze
        @_length = @_injections.length
        @_final = @_length - 1
        @_search_order = ( 0 ... @_length ).to_a
      end

      def add_grammatical_injection k, impl
        @_injections.push GrammaticalInjection___[ k, impl ] ; nil
      end

      def stream_via_array ary
        stream_via_scanner Scanner_[ ary ]
      end

      def stream_via_scanner scn

        d = nil

        when_found = -> do
          inj = @_injections.fetch d
          x = inj.injection_implementation.gets_one_item_via_scanner scn
          if x
            QualifiedItem___[ x, inj.injection_identifier ]
          else
            ::Kernel._COVER_ME__when_falseish_result_from_grammatical_injection__
          end
        end

        when_some = -> do
          k = scn.head_as_is
          d = __find_it k
          if d
            when_found[]
          else
            raise ::NameError, __say_keyword_not_found( k )
          end
        end

        Common_.stream do
          when_some[] unless scn.no_unparsed_exists
        end
      end

      def __say_keyword_not_found k
        "keyword not found in grammar: '#{ k }' (and this message is not covered)"  # #cover-me
      end

      def __find_it k
        d = @_keyword_cache[ k ]
        if ! d
          d = __look_it_up k
          if d
            @_keyword_cache[ k ] = d
          end
        end
        d
      end

      def __look_it_up k
        dd = @_length
        until dd.zero?
          dd -= 1
          d = @_search_order.fetch dd
          inj = @_injections.fetch d
          if inj.injection_implementation.is_keyword k
            found = true
            break
          end
        end
        if found
          if @_final != dd
            # near [#034.2] adapting optimising
            @_search_order[ dd, 1 ] = EMPTY_A_
            @_search_order.push d
          end
          d
        end
      end

      def DEREFERENCE_INJECTION k  # (experiment for [br] under [bs])
        d = @_length - 1
        begin
          inj = @_injections.fetch d
          if k == inj.injection_identifier
            found = inj.injection_implementation
            break
          end
          d.zero? && break
          d -= 1
          redo
        end while above
        found || fail
      end
    # -
    # ==

    QualifiedItem___ = ::Struct.new :item, :injection_identifier

    GrammaticalInjection___ = ::Struct.new :injection_identifier, :injection_implementation

    # ==
    # ==
  end

  class IambicGrammar::ItemGrammar_LEGACY  # see [#005]

    # (this is the legacy, more specialized implementatio

    class << self

      alias_method :__orig_new, :new

      def new adj_i_a, keyword_sym, pp_i_a

        ::Class.new( self ).class_exec do

          # const_set :ADJ_I_A__, adj_i_a.freeze

          const_set :ADJ_H___, ::Hash[ adj_i_a.map { |i| [ i, i ] } ].freeze

          const_set :Adj_Struct___, Sexp__.new( * adj_i_a )

          const_set :KW_SYM__, keyword_sym

          # const_set :PP_I_A__, pp_i_a.freeze

          const_set :PP_H___, ::Hash[ pp_i_a.map { |i| [ i, true ] } ].freeze

          const_set :PP_Struct___, Sexp__.new( * pp_i_a )

          const_set :SP_Struct___, ::Struct.new( :adj, :keyword_value_x, :pp )

          class << self
            alias_method :new, :__orig_new
            private :new
          end

          self
        end
      end

      # ~ singleton methods for subclasses

      def parse_one_item_via_iambic_fully x_a

        scn = Common_::Scanner.via_array x_a
        scn_ = simple_stream_of_items_via_polymorpic_stream scn
        x = scn_.gets
        if x
          if scn.unparsed_exists
            raise ::ArgumentError
          end
          x
        else
          raise ::ArgumentError
        end
      end

      def simple_stream_of_items_via_polymorpic_array x_a

        _scn = Scanner_[ x_a ]

        simple_stream_of_items_via_polymorpic_stream _scn
      end

      def simple_stream_of_items_via_polymorpic_stream _scn

        new _scn
      end
    end  # >>

    class Sexp__ < ::Struct

      # hack a struct to remember what keys were used in its making

      class << self
        def new * a
          if a.length.zero?
            EMPTY_NT___
          else
            super
          end
        end
      end

      def initialize( * )
        @_key_set = Home_.lib_.stdlib_set.new
        super
      end

      def keys
        @_key_set.to_a
      end

      alias_method :struct_each_pair, :each_pair

      def each_pair & p
        if p
          @_key_set.each do | k |
            p[ [ k, self[ k ] ] ]
          end
        else
          enum_for __method__
        end
      end

      def []= k, x
        @_key_set.add? k
        super
      end
    end

    EMPTY_NT___ = :this_nonterminal_symbol_is_empty

    def initialize st

      gets_one = -> do  # assume token stream is not empty

        o = self.class

        adj_h = o::ADJ_H___
        adj_struct = o::Adj_Struct___

        keyword_sym = o::KW_SYM__

        pp_h = o::PP_H___
        pp_struct = o::PP_Struct___

        sp_struct = o::SP_Struct___

        adj_sct = nil

        # parse any adjectives

        begin

          if adj_h[ st.head_as_is ]

            adj_sct ||= adj_struct.new
            adj_sct[ st.gets_one ] = true
            if st.unparsed_exists
              redo
            end
          end
          break
        end while nil

        # parse the name

        if st.unparsed_exists && keyword_sym == st.head_as_is

          st.advance_one

          sp_sct = sp_struct.new adj_sct, keyword_sym

          pp_sct = nil

          # parse any prepositional phrases

          begin

            st.unparsed_exists or break

            if pp_h[ st.head_as_is ]

              pp_sct ||= pp_struct.new

              _k = st.gets_one

              pp_sct[ _k ] = st.gets_one

              redo
            end
            break
          end while nil

          if pp_sct
            sp_sct.pp = pp_sct
          end

          sp_sct

        elsif adj_sct

          raise ::ArgumentError, __say_failure( pp_h, adj_h, st )
        end
      end

      @__gets = -> do

        if st.no_unparsed_exists
          NIL_
        else
          gets_one[]
        end
      end

      NIL_
    end

    def gets
      @__gets.call
    end

    def __say_failure pp_h, adj_h, st

      y = []

      y << "encountered unrecognized token `#{ st.head_as_is }` #{
        }before reaching required token `#{ self.class::KW_SYM__ }`"

      if adj_h.length.nonzero?
        y << "an adjective among #{ adj_h.keys * ', ' }"
      end

      if pp_h.length.nonzero?
        y << "the start of a prepositional phrase from among (#{
          }#{ pp_h.keys * ', ' })"
      end

      y.join ' or '
    end
  end

  class IambicGrammar

    # ==

    class ItemGrammarInjection < Common_::SimpleModel

      # (meant to realize "entity killer", and be a broader replacement for legacy item grammar)

      define_method :redefine, self::DEFINITION_FOR_THE_METHOD_CALLED_REDEFINE

      attr_writer(
        :item_class,
        :postfixed_modifiers,
        :prefixed_modifiers
      )

      # -- "read"

      def STREAM_VIA_TOKEN_SCANNER scn  # [bs]
        Common_.stream do
          unless scn.no_unparsed_exists
            gets_one_item_via_scanner scn
          end
        end
      end

      def gets_one_item_via_scanner_fully scn
        item = gets_one_item_via_scanner scn
        if scn.no_unparsed_exists
          item
        else
          self._COVER_ME__scanner_had_unparsed_content_after_parsing_item
        end
      end

      def gets_one_item_via_scanner scn
        GetsOneItem___.new(
          scn, @prefixed_modifiers, @postfixed_modifiers, @item_class
        ).execute
      end

      def is_keyword k
        @prefixed_modifiers.method_defined? k
      end

      attr_reader(
        :postfixed_modifiers,
        :prefixed_modifiers,
      )
    end

    # ==

    class GetsOneItem___

      # every grammar in this category of grammars has what we call a "pivot
      # point" keyword, which is that keyword around which the parse "pivots"
      # from being in the "head" state (where prefixed modifers are parsed)
      # to the "tail" state (where any postfixed modifiers are parsed).
      #
      # (this keyword is classically `property` but it could be anything.)
      #
      # it's convenient to implement the pivotpoint keyword itself as a
      # prefixed modifier. as such all surface expressions of item will
      # have least one prefixed modifier expression.
      #
      # we then conceive of the parse as being broken up into one and
      # possibly two "legs" (as in "leg of a journey"), corresponding to
      # the parsing of the one or more prefixed then zero or more postfixed
      # modifiers: when parsing the prefixed modifiers we are in the "head"
      # leg and when parsing the any postfix modifiers we call that the
      # "tail" leg (to mix metaphors within a category of metaphors).

      def initialize scn, pre, post, ic
        @item_class = ic
        @prefixed_modifiers = pre
        @postfixed_modifiers = post
        @scanner = scn
      end

      def execute

        @item_class.define do |o|
          ok = __parse_head_leg o
          ok &&= __maybe_parse_tail_leg o
          ok && o.finish
          NIL
        end
      end

      def __maybe_parse_tail_leg o

        if @scanner.no_unparsed_exists
          KEEP_PARSING_

        elsif @postfixed_modifiers.method_defined? @scanner.head_as_is

          __do_parse_tail_leg o

        else

          # (this is a streaming parse. although we could peek to see if
          # the scanner head looks like a next item, there is no reason to.)

          KEEP_PARSING_
        end
      end

      def __do_parse_tail_leg o

        # (#coverpoint1.1: tail leg)

        leg = Leg__.new o, @scanner, self
        leg.extend @postfixed_modifiers
        begin
          ok = leg.__send__ @scanner.gets_one
          ok || break
          @scanner.no_unparsed_exists && break
        end while @postfixed_modifiers.method_defined? @scanner.head_as_is
        ok
      end

      def __parse_head_leg o

        leg = Leg__.new o, @scanner, self
        leg.extend @prefixed_modifiers
        @_did_pivot = false
        begin
          ok = leg.__send__ @scanner.gets_one
        end while ok && ! @_did_pivot
        ok
      end

      def transition_from_prefix_to_postfix
        @_did_pivot = true
      end
    end

    # ==

    class Leg__
      def initialize pt, scn, pa
        @parse_tree = pt
        @parser = pa
        @scanner = scn
      end
    end

    # ==
    # ==
    # ==
    # ==

    NOTHING_ = nil

    # ==
  end
end
# #history: spike "iambic grammar" into "item grammar"
