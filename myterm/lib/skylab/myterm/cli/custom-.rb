module Skylab::MyTerm

  class CLI

    module Custom_

      # the non-interactive CLI client requires work to accomodate
      # our custom syntax for setting the adapter.

      class Compound_usage_strings < Common_::Dyadic

        # ("sa" = "syntax assembly")

        def initialize y, sa
          @_sa = sa ; @_y = y
        end

        def execute

          # pns [ -a{i|p} ] doot foot <action> [..]
          # pns [ -a{i|p} ] doot foot -h <action>

          # pns -ai doot foot <action> [..]
          # pns -ai doot foot -h <action>

          ce = Common_Elements__._via_syntax_assembly @_sa
          consts = ce.CLI.class  # eek/meh
          eli = consts::ELLIPSIS_PART
          help = consts::SHORT_HELP_OPTION

          # --

          ada = if ce.adapter_is_selected

            ce.word_for_option_selecting_selected_adapter
          else
            "[ #{ ce.__word_for_option_for_chose_any_adapter } ]"  # "[ -a{i|p} ]"
          end

          pns, tail, action = ce.to_three_for @_sa

          @_y << "#{ pns } #{ ada }#{ tail } #{ action } #{ eli }"

          @_y << "#{ pns } #{ ada }#{ tail } #{ help } #{ action }"

          NOTHING_
        end
      end

      class Operation_usage_string < Common_::Monadic

        def initialize sa
          @_sa = sa
        end

        def execute

          ce = Common_Elements__._via_syntax_assembly @_sa

          @_sa.begin_expression_into ""

          # -- instead of: @_sa.add_word @_sa.formal_action.subprogram_name_string

          @_sa.add_word ce.program_name_string

          if ce.adapter_is_selected

            @_sa.add_word ce.word_for_option_selecting_selected_adapter

          else
            self._K_cover_me_easy
          end

          st = ce.to_non_root_frame_stream

          begin
            fr = st.gets
            fr or break
            @_sa.add_word fr.subprogram_name_slug
            redo
          end while nil

          # --

          @_sa.express_option_parser
          @_sa.express_arguments
          _ = @_sa.release
          _  # #todo
        end
      end

      # ==

      Compound_custom_sections = -> hf_va do

        ce = Common_Elements__.of hf_va.modality_frame

        if ! ce.adapter_is_selected

          hf_va.express_sections_by do |o|

            o.yield :section, :name_symbol, :option

            o.yield( :item,
              :moniker, '-a, --adapter=X',
              :description, -> y do
                y << "indicate an image output adapter"
              end,
            )
          end
        end
      end

      # ==

      class Invite < Common_::Monadic

        # the same logic as the common invite line, plus one element

        def initialize inv
          @invite = inv
        end

        def execute

          _ce = Common_Elements__._via_invite @invite

          @invite.didactic_ARGV_string = _ce.assemble_short_didactic_ARGV_string

          @invite.send @invite.method_name

          NOTHING_
        end
      end

      # ===

      class Common_Elements__

        # things like invite lines and usage lines have elements in common,
        # but we don't want their various renderings to be tightly bound
        # to each other so we use this crutch of memoizing a subject
        # instance *into* the modality frame so that whichever appendage
        # is rendered first catalyzes work that the other can reuse without
        # either of them having to know that this is what they're doing.

        class << self

          def _via_syntax_assembly sa
            of sa.formal_action.modality_frame
          end

          def _via_invite inv

            invo_refl = inv.invocation_reflection
            _top_frame = if invo_refl
              invo_refl.modality_frame
            else
              inv.CLI.top_frame
            end

            of _top_frame
          end

          def of top_frame

            top_frame.all_purpose_cache[ :_common_elements_ ] ||= new top_frame
          end

          private :new
        end  # >>

        def initialize top_frame

          st = top_frame.to_frame_stream_from_bottom

          root_frame = st.gets

          appearance = root_frame.ACS

          _ = appearance.kernel_.silo( :Adapters ).to_asset_reference_stream

          hs_a = Home_.lib_.basic::Hash::Hotstrings[ _.map_by( & :stem ) ]

          adapter = appearance.adapter

          if adapter
            yes = true

            against = adapter.name.as_slug

            hs = hs_a.detect do |hs_|
              s = hs_.hotstring
              s == against[ 0, s.length ]
            end

            @_word_for_option_selecting_selected_adapter = "-a#{ hs.hotstring }"
          else
            @_word_for_option_for_selecting_any_adapter = "-a{#{ hs_a.map( & :hotstring ).join '|' }}"
          end

          tail = ""
          fr_a = []
          begin
            fr = st.gets
            fr or break
            fr_a.push fr
            tail << SPACE_
            tail << fr.subprogram_name_slug
            redo
          end while nil

          @adapter_is_selected = yes
          @CLI = root_frame.CLI
          @__non_root_frame_array = fr_a
          @program_name_string = root_frame.get_program_name_string
          @_tail = tail
        end

        def assemble_short_didactic_ARGV_string
          _assemble_didactic_ARGV_string false
        end

        def assemble_didactic_ARGV_string
          _assemble_didactic_ARGV_string true
        end

        def _assemble_didactic_ARGV_string is_long

          buffer = @program_name_string.dup

          if @adapter_is_selected

            buffer << SPACE_ << @_word_for_option_selecting_selected_adapter

          elsif is_long

            buffer << SPACE_ << "[#{ @_word_for_option_for_selecting_any_adapter }]"
          end

          st = to_non_root_frame_stream
          begin
            fr = st.gets
            fr or break
            buffer << SPACE_
            buffer << fr.subprogram_name_slug
            redo
          end while nil

          buffer << SPACE_
          buffer << @CLI.class::SHORT_HELP_OPTION  # eek
          buffer
        end

        def to_three_for sa
          _ = __action_placeholder_moniker sa
          [ @program_name_string, @_tail, _ ]
        end

        def __action_placeholder_moniker sa

          _prp = sa.formal_action.properties.fetch :action

          @CLI.expression_agent.calculate do
            par _prp
          end
        end

        def to_non_root_frame_stream
          Common_::Stream.via_nonsparse_array @__non_root_frame_array
        end

        def word_for_option_selecting_selected_adapter
          @_word_for_option_selecting_selected_adapter
        end

        def __word_for_option_for_chose_any_adapter
          @_word_for_option_for_selecting_any_adapter
        end

        attr_reader(
          :adapter_is_selected,
          :CLI,
          :program_name_string,
        )
      end

      # ==
    end
  end
end
