module Skylab::MyTerm

  class CLI

    module Custom_

      # apparently darently

      Usage_String_Methods__ = Module.new

      class Compound_usage_strings < Callback_::Actor::Dyadic

        include Usage_String_Methods__

        def initialize y, sa
          @_sa = sa ; @_y = y
        end

        def execute
          _orient
          if @_has_adapter
            __express_lines_when_adapter_is_selected
          else
            __express_lines_when_no_adapter
          end
        end

        def __express_lines_when_adapter_is_selected

          # pns -ai doot foot <action> [..]
          # pns -ai doot foot -h <action>

          self._TODO_write_me__express_lines_when_adapter_is_selected_README_easy

          # to cover this, find an adapter-specific compound node #todo
          # it's so similar to the next method that they should share
          # a "lenticular" method (one that does something different only
          # in the middle)

        end

        def __express_lines_when_no_adapter

          # pns [ -a{i|p} ] doot foot <action> [..]
          # pns [ -a{i|p} ] doot foot -h <action>

          ___init_several_strings_by_consuming_frame_stream

          consts = @CLI.class  # EEK
          _eli = consts::ELLIPSIS_PART
          _h = consts::SHORT_HELP_OPTION

            _ = __assemble_word_for_option_for_chose_any_adapter
            ada = "[ #{ _ } ]"  # "[ -a{i|p} ]"

          @_y << "#{ @_PNS } #{ ada }#{ @_tail } #{ @_action_s } #{ _eli }"

          @_y << "#{ @_PNS } #{ ada }#{ @_tail } #{ _h } #{ @_action_s }"

          NOTHING_
        end

        def ___init_several_strings_by_consuming_frame_stream

          tail = ""

          begin
            fr = @_st.gets
            fr or break
            tail << SPACE_
            tail << fr.subprogram_name_slug
            redo
          end while nil

          _prp = @_sa.formal_action.properties.fetch :action

          @_action_s = @CLI.expression_agent.calculate do
            par _prp
          end

          @_PNS = @_root_frame.get_program_name_string

          @_tail = tail
          NIL_
        end
      end

      class Operation_usage_string < Callback_::Actor::Monadic

        include Usage_String_Methods__

        def initialize sa
          @_sa = sa
        end

        def execute
          _orient
          if @_has_adapter
            __string_when_adapter
          else
            self.__DECIDE_ME_string_when_no_adapter
          end
        end

        def __string_when_adapter

          @_sa.begin_expression_into ""

          # -- instead of: @_sa.add_word @_sa.formal_action.subprogram_name_string

          @_sa.add_word @_root_frame.get_program_name_string

          @_sa.add_word "-a#{ _find_shortest_hotstring }"

          begin
            fr = @_st.gets
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

      module Usage_String_Methods__

        def _orient
          @_st = @_sa.formal_action.to_frame_stream_from_bottom
          @_root_frame = @_st.gets
          @CLI = @_root_frame.CLI
          @_appearance = @_root_frame.ACS
          if @_appearance.adapter
            @_has_adapter = true
          else
            @_has_adapter = false
          end
          NIL_
        end

        def __assemble_word_for_option_for_chose_any_adapter
          _ = _hotstring_snapshot._hotstrings.map( & :hotstring ).join '|'
          "-a{#{ _ }}"
        end

        def _find_shortest_hotstring

          _hotstring_snapshot._hotstring_of_active_adapter
        end

        def _hotstring_snapshot
          Hotstring_Snapshot__.in @_appearance
        end
      end

      # ==

      Compound_custom_sections = -> hf_va do

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

      # ==

      class Invite < Callback_::Actor::Monadic

        # the same logic as the common invite line, plus one element

        def initialize inv
          @CLI = inv.CLI
          @invite = inv
        end

        def execute

          st = @CLI.top_frame.to_frame_stream_from_bottom
          root_frame = st.gets
          appe = root_frame.ACS

          buffer = root_frame.get_program_name_string

          if appe.adapter
            _hss = Hotstring_Snapshot__.in root_frame.ACS
            _ = _hss._hotstring_of_active_adapter
            buffer << SPACE_ << "-a#{ _ }"
          end

          begin
            fr = st.gets
            fr or break
            buffer << SPACE_
            buffer << fr.subprogram_name_slug
            redo
          end while nil

          buffer << SPACE_
          buffer << @CLI.class::SHORT_HELP_OPTION  # eek

          @invite.didactic_ARGV_string = buffer
          @invite.express
          NOTHING_
        end
      end

      # ==

      class Hotstring_Snapshot__

        class << self
          def in appe
            appe.CLI_memo_[ :_hss_ ] ||= new( appe )
          end
          private :new
        end  # >>

        def initialize appe
          @appearance = appe
        end

        def _hotstring_of_active_adapter
          ( @___hs_qk ||= Callback_::Known_Known[ ___etc ] ).value_x
        end

        def ___etc

          against = @appearance.adapter.name.as_slug

          _hs = _hotstrings.detect do |hs_|
            s = hs_.hotstring
            s == against[ 0, s.length ]
          end

          _hs.hotstring
        end

        def _hotstrings
          @___hss ||= ___amass_hotstrings
        end

        def ___amass_hotstrings

          _ = @appearance.kernel_.silo( :Adapters ).to_load_ticket_stream

          Home_.lib_.basic::Hash::Hotstrings[ _.map_by( & :stem ) ]
        end
      end
    end
  end
end
