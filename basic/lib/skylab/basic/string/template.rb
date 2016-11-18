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

      def initialize

        @is_not_parsed = true
        @couplet_mapper = nil
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

      def couplet_mapper=
        @couplet_mapper = gets_one_polymorphic_value
        KEEP_PARSING_
      end

    public

      def call actuals
        express_into_against "", actuals
      end

      def express_into_against y, actuals

        st = _parse_tree.__parse_tree_to_couplet_stream

        begin

          couplet = st.gets
          couplet or break

          s = couplet._static_string
          if s
            y << s
          end

          k = couplet.name_symbol
          if k

            had = true
            x = actuals.fetch k do
              had = false
            end

            if had
              if x  # #spot-1
                y << x
              end
            else
              y << couplet.parameter_occurrence_surface_string
            end
          end

          redo
        end while nil

        y
      end

      def first_margin_for sym
        _parse_tree._occurrence_box.fetch( sym ).margin_string
      end

      def formal_variable_box
        _parse_tree._occurrence_box
      end

      def to_parameter_occurrence_stream
        _parse_tree._occurrence_box.to_value_stream
      end

      def _parse_tree
        if @is_not_parsed
          @is_not_parsed = false
          @parse_tree = Parse___.new( @buid, @couplet_mapper ).parse
        end
        @parse_tree
      end

      class Parse___

        def initialize buid, fvm
          @buid = buid
          @couplet_mapper = fvm
        end

        def parse

          item_a = [] ; surface_h = {}

          formal_box = Common_::Box.new
          marg = Margin_Engine__.new
          st = ___parse_to_couplet_stream

          begin
            o = st.gets
            o or break

            if @couplet_mapper
              o = @couplet_mapper[ o ]
            end

            o.__init_any_name_symbol

            sym = o.name_symbol
            if ! sym
              item_a.push o
              redo
            end

            subsequent_sighting = true
            _a = surface_h.fetch sym do
              subsequent_sighting = false
              surface_h[ sym ] = []
            end
            _a.push item_a.length

            item_a.push o

            if subsequent_sighting
              redo
            end

            marg.take o._static_string

            _offset = @__volatile_string_scanner.pos -
              o.parameter_occurrence_surface_string.length

            occu = Parameter_Occurrence___.new(
              marg.give,
              _offset,
              o,
            )

            formal_box.add occu.name_symbol, occu

            redo
          end while nil

          Parse_Tree___.new( formal_box, item_a, surface_h )
        end

        def ___parse_to_couplet_stream

          var_rx = VAR_RX__

          plain_rx = /(?: (?! #{ var_rx.source } ) . )+/mx

          scn = Home_.lib_.string_scanner @buid.whole_string
          @__volatile_string_scanner = scn

          p = -> do
            if scn.eos?
              p = EMPTY_P_
              remove_instance_variable :@__volatile_string_scanner
              NOTHING_
            else
              Static_then_Parameter_Strings___.new scn.scan( plain_rx ), scn.scan( var_rx )
            end
          end

          Common_.stream do
            p[]
          end
        end
      end

      class Static_then_Parameter_Strings___  # a.k.a "couplet"

        # we parse tempate bytes by turning them into a stream of
        # "couplets" where each couplet is one static string and one
        # parameter surface string

        def initialize plain_s, surface_s

          @_static_string = plain_s
          @parameter_occurrence_surface_string = surface_s
          @unparsed_surface_content_string = if surface_s
            VAR_RX__.match( surface_s )[ 1 ]
          end
        end

        attr_writer(
          :name_symbol,
          :unparsed_surface_content_string,
        )

        def __init_any_name_symbol
          s = @unparsed_surface_content_string
          if s
            sym = Name_symbol_via_surface_string__[ s ]
            @name_symbol = sym
          end
          nil
        end

        attr_reader(
          :name_symbol,
          :_static_string,
          :parameter_occurrence_surface_string,
          :unparsed_surface_content_string,
        )
      end

      VAR_RX__ = Home_::String.mustache_regexp

      Name_symbol_via_surface_string__ = -> s do
        s.strip.intern
      end

      class Parse_Tree___

        def initialize occu_bx, coup_a, surface_h

          @_couplets = coup_a
          @_hash = surface_h
          @_occurrence_box = occu_bx
        end

        def __parse_tree_to_couplet_stream
          Common_::Stream.via_nonsparse_array @_couplets
        end

        attr_reader(
          :_occurrence_box,
        )
      end

      class Parameter_Occurrence___

        def initialize s, d, o
          @margin_string = s
          @name_symbol = o.name_symbol
          @offset = d
          @surface_string = o.parameter_occurrence_surface_string
        end

        attr_reader(
          :margin_string,
          :name_symbol,
          :surface_string,
          :offset,
        )
      end

      Margin_Engine__ = Common_::Session::Ivars_with_Procs_as_Methods.new :give, :take do

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
# #pending-rename: just do it
# #note-110 :+#tombstone
