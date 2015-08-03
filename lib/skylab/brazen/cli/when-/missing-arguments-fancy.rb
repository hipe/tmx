module Skylab::Brazen

  class CLI

    class When_::Missing_Arguments_Fancy < As_Bound_Call_

      def initialize ev, help_renderer

        @ev = ev
        @hr = help_renderer
      end

      def produce_result o=nil

        if o
          self.class.new( @ev, o )._produce_result
        else
          _produce_result
        end
      end

      def _produce_result

        o = @hr

        _ = __render_syntax

        o.y << "expecting: #{ _ }"

        o.express_primary_usage_line_

        o.express_invite_to_general_help

        GENERIC_ERROR
      end

      def __render_syntax  # #storypoint-920

        slice = @ev.syntax_slice
        _st = slice.to_argument_stream
        arg = _st.gets
        _missing_idx = arg.syntax_index

        syntax = @ev.any_full_syntax

        a = [ arg ]
        ( _missing_idx - 1 ).downto( 0 ).each do | d |  # neg ok
          arg_ = syntax[ d ]

          if :req == arg_.reqity_symbol
            break
          end
          a.unshift arg_
        end

        local_emph_idx = a.length - 1
        _my_slice = slice.class.new a

        __render_this_syntax _my_slice, local_emph_idx .. local_emph_idx
      end

      def __render_this_syntax stx, em_range  # #storypoint-435

        st = stx.to_argument_stream
        arg = st.gets

        if arg

          y = []
          d = 0
          begin
            s = __render_arg_text arg
            if em_range.include? d
              s = @hr.expression_agent.calculate do
                highlight s
              end
            end
            y.push s
            arg = st.gets
            arg or break
            d += 1
            y.push SPACE_
            redo
          end while nil

          y.join EMPTY_S_

        else
          self._COVER_ME
        end
      end

      def __render_arg_text arg  # #storypoint-450

        s, s__ = CLI_::Isomorphic_Methods_Client::Models_::
          Isomorphic_Method_Parameters::Reqity_brackets[ arg.reqity_symbol ]

        _s_ = @hr.expression_agent.calculate do
          render_property_as_argument_ arg
        end

        "#{ s }#{ _s_ }#{ s__ }"
      end
    end
  end
end

# :#tombstone: eulogy for HUGE [hl] action instance methods (large)
