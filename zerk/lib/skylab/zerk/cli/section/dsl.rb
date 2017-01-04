module Skylab::Zerk

  module CLI

    class Section::DSL  # :[#061.2].

      Require_fields_lib_[]

      Parsing_Methods__ = ::Module.new

      include Parsing_Methods__

      def initialize invex

        @_has_open_section = false
        @_invex = invex
        @_num_lines = MAX_DESC_LINES__
      end

      def yield * x_a
        receive x_a
      end

      def receive x_a

        st = Common_::Polymorphic_Stream.via_array x_a

        if @_has_open_section

          _did = @_section.process_polymorphic_stream_all_or_nothing st

          if ! _did
            _flush_open_section
            do_it = true
          end
        else
          do_it = true
        end

        if do_it
          process_polymorphic_stream_fully st
        end
        NIL
      end

    private

      def allow_item_descriptions_to_have_N_lines=
        @_num_lines = @_st.gets_one ; nil
      end

      def section=
        if @_has_open_section
          self._A
        else
          @_has_open_section = true
          @_section = Section___.new( @_st, @_num_lines, @_invex ).execute
        end
        NIL
      end

    public

      def finish
        if @_has_open_section
          _flush_open_section
        end
        @_last_x  # or else what are we doing here
      end

      def _flush_open_section  # assume has.

        section = remove_instance_variable :@_section
        @_last_x = section.flush
        @_has_open_section = false
        NIL
      end

      # ==

      class Section___

        include Parsing_Methods__

        def initialize st, d, invex
          @_invex = invex
          @_items = []
          @_num_lines = d
          @_st = st
        end

        def execute
          via_polymorphic_stream_parse_fully
          self
        end

        # --

        # (we are mixing keywords for two distinct contexts but meh..)

        def item=
          _item = Item___.new( @_st ).execute
          @_items.push _item ; nil
        end

        def name_symbol=
          @_name = Common_::Name.via_variegated_symbol @_st.gets_one ; nil
        end

        # --

        def flush

          expag = @_invex.expression_agent
          invex = @_invex
          item_st = Common_::Stream.via_nonsparse_array @_items
          num_lines = @_num_lines
          op = invex.option_parser
          section_name_function = remove_instance_variable :@_name

          # --

          _any = invex.express_section(
            :header, section_name_function.as_human,
            :pluralize,
            :wrapped_second_column, op,
          ) do |y|

            begin
              item = item_st.gets
              item or break

              _ = item.moniker_proc[ expag ]
              __ = Field_::N_lines[ num_lines, expag, item ]
              y.yield _, ( __ || EMPTY_A_ )

              redo
            end while nil
          end

          _any
        end
      end

      # ==

      class Item___

        include Parsing_Methods__

        def initialize st
          @description_proc = nil  # hi.
          @_st = st
        end

        def execute
          via_polymorphic_stream_parse_fully
          self
        end

        def descriptor=
          _atr = @_st.gets_one
          @description_proc = Field_::Has_description[ _atr ]  # ABUSE
          NIL
        end

        def description=
          @description_proc = @_st.gets_one ; nil
        end

        def moniker=
          s = @_st.gets_one
          @moniker_proc = -> _expag { s } ; nil
        end

        def moniker_proc=
          @moniker_proc = @_st.gets_one ; nil
        end

        attr_reader(
          :description_proc,
          :moniker_proc,
        )
      end

      # ==

      module Parsing_Methods__

        def process_polymorphic_stream_all_or_nothing st

          if respond_to? :"#{ st.current_token }="
            process_polymorphic_stream_fully st
            ACHIEVED_
          else
            UNABLE_
          end
        end

        def process_polymorphic_stream_fully st
          # (rewriting this common method as bespoke)
          @_st = st
          via_polymorphic_stream_parse_fully
          NIL
        end

        def via_polymorphic_stream_parse_fully
          begin
            send :"#{ @_st.gets_one }="
          end until @_st.no_unparsed_exists
          remove_instance_variable :@_st
          NIL
        end
      end

      # ==

      MAX_DESC_LINES__ = 2  # for now dup

      # ==
    end
  end
end
# #history: moved here from [br]
