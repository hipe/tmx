module Skylab::Basic

  module String

    class Template__  # see [#028]

      class << self

        def [] template_str, param_h
          via_string( template_str ).call param_h
        end

        def string_has_variable str, param_name
          str.include? Parametize__[ param_name ]
        end

        def via_path path
          new_with :path, path
        end

        def via_string string
          new_with :string, string
        end
      end  # >>

      Parametize__ = -> s do
        "{{#{ s }}}"  # super duper non-robust for now
      end

      Attributes_actor_[ self ]

      def initialize & edit_p

        @surface_pair_mapper = nil
        @is_not_parsed = true
        instance_exec( & edit_p )
      end

      def members
        [ :call, :to_formal_variable_stream ]
      end

    private

      def path=
        @buid = Home_.lib_.brazen.byte_upstream_identifier.via_path(
          gets_one_polymorphic_value )
        KEEP_PARSING_
      end

      def string=
        @buid = Home_.lib_.brazen.byte_upstream_identifier.via_string(
          gets_one_polymorphic_value )
        KEEP_PARSING_
      end

      def surface_pair_mapper=
        @surface_pair_mapper = gets_one_polymorphic_value
        KEEP_PARSING_
      end

    public

      def call actuals
        __render_into_against( [], actuals ) * EMPTY_S_
      end

      def __render_into_against y, actuals

        st = _parse_tree.to_pair_stream

        begin

          pair = st.gets
          pair or break

          s = pair.plain_s
          if s
            y << s
          end

          k = pair.name_symbol
          if k
            had = true
            x = actuals.fetch k do
              had = false
            end
            if had
              y << x
            else
              y << pair.surface_s
            end
          end

          redo
        end while nil

        y
      end

      def first_margin_for sym
        _parse_tree.fo_bx.fetch( sym ).margin_s
      end

      def formal_variable_box
        _parse_tree.fo_bx
      end

      def to_formal_variable_stream
        _parse_tree.fo_bx.to_value_stream
      end

      def _parse_tree
        if @is_not_parsed
          @is_not_parsed = false
          @parse_tree = Parse___.new( @buid, @surface_pair_mapper ).parse
        end
        @parse_tree
      end

      class Parse___

        def initialize buid, fvm
          @buid = buid
          @surface_pair_mapper = fvm
        end

        def parse

          pair_a = [] ; surface_h = {}

          formal_box = Callback_::Box.new
          marg = Margin_Engine__.new
          st = __to_pair_stream

          begin
            pair = st.gets
            pair or break

            if @surface_pair_mapper
              pair = @surface_pair_mapper[ pair ]
            end

            pair.resolve_any_name_symbol_

            sym = pair.name_symbol
            if ! sym
              pair_a.push pair
              redo
            end

            subsequent_sighting = true
            _a = surface_h.fetch sym do
              subsequent_sighting = false
              surface_h[ sym ] = []
            end
            _a.push pair_a.length

            pair_a.push pair

            if subsequent_sighting
              redo
            end

            marg.take pair.plain_s

            fo = Formal___.new( marg.give,  # margin
              ( @scn.pos - pair.surface_s.length ),  # offset
              pair )

            formal_box.add fo.name_symbol, fo

            redo
          end while nil

          Parse_Tree___.new( formal_box, pair_a, surface_h )
        end

        def __to_pair_stream

          var_rx = VAR_RX__

          plain_rx = /(?: (?! #{ var_rx.source } ) . )+/mx

          scn = Home_.lib_.string_scanner @buid.whole_string
          @scn = scn

          p = -> do
            if scn.eos?
              p = EMPTY_P_
              nil
            else
              Pair___.new scn.scan( plain_rx ), scn.scan( var_rx )
            end
          end

          Callback_.stream do
            p[]
          end
        end
      end

      class Pair___

        def initialize plain_s, surface_s
          @plain_s = plain_s
          @surface_s = surface_s
          @unparsed_surface_content_s = if surface_s
            VAR_RX__.match( surface_s )[ 1 ]
          end
        end

        def members
          [ :name_symbol, :plain_s, :surface_s, :unparsed_surface_content_s ]
        end

        attr_reader :plain_s, :surface_s
        attr_accessor :name_symbol, :unparsed_surface_content_s

        def resolve_any_name_symbol_
          s = @unparsed_surface_content_s
          if s
            sym = Name_symbol_via_surface_string__[ s ]
            @name_symbol = sym
          end
          nil
        end
      end

      VAR_RX__ = Home_::String.mustache_regexp

      Name_symbol_via_surface_string__ = -> s do
        s.strip.intern
      end

      class Parse_Tree___
        def initialize formal_bx, pair_a, surface_h
          @fo_bx = formal_bx
          @a = pair_a
          @h = surface_h
        end
        def members
          [ :a, :fo_box, :h ]
        end
        attr_reader :a, :fo_bx, :h

        def to_pair_stream
          a = @a
          Callback_::Stream.via_times a.length do | d |
            a.fetch d
          end
        end
      end

      class Formal___

        def initialize s, d, x
          @margin_s = s
          @offset = d
          @pair = x
        end

        def members
          [ :margin_s, :name_symbol, :offset, :surface_s ]
        end

        attr_reader :margin_s, :offset

        def name_symbol
          @pair.name_symbol
        end

        def surface_s
          @pair.surface_s
        end
      end

      Margin_Engine__ = Callback_::Session::Ivars_with_Procs_as_Methods.new :give, :take do

        # read #about-margins

        def initialize

          is_fresh_line = true ; mgn = nil

          fresh_line = -> rpos, s do
            mgn = if rpos  # let margin be the empty string for the relevant params
              s[ rpos + 1 .. -1 ]
            else
              s
            end
            is_fresh_line = false ; nil
          end

          see = -> s do
            rpos = s.rindex NEWLINE_
            ! is_fresh_line and rpos and is_fresh_line = true
            is_fresh_line and fresh_line[ rpos, s ]
          end

          @take = -> s do
            mgn = nil  # allow for multiple takes with no give
            s and see[ s ]
            nil
          end

          @give = -> do
            x = mgn ; mgn = nil ; x
          end
        end
      end

    end
  end
end
# #note-110 :+#tombstone
