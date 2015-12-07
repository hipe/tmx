module Skylab::Brazen

  module CLI_Support

    class When::Missing_Arguments_Fancy < As_Bound_Call

      def initialize ev, invocation_expression

        @_expression = invocation_expression
        @_event = ev
      end

      def produce_result o=nil

        if o
          self.class.new( @_event, o )._produce_result
        else
          _produce_result
        end
      end

      def _produce_result

        o = @_expression

        _ = __render_syntax

        o.line_yielder << "expecting: #{ _ }"

        o.express_primary_usage_line

        o.express_invite_to_general_help :because, :argument

        GENERIC_ERROR_EXITSTATUS
      end

      def __render_syntax

        slice = @_event.syntax_slice
        _st = slice.to_argument_stream
        arg = _st.gets
        _missing_idx = arg.syntax_index

        syntax = @_event.any_full_syntax

        a = [ arg ]
        ( _missing_idx - 1 ).downto( 0 ).each do | d |  # neg ok
          arg_ = syntax[ d ]

          if :req == arg_.reqity_symbol_
            break
          end
          a.unshift arg_
        end

        local_emph_idx = a.length - 1
        _my_slice = slice.class.new a

        __render_this_syntax _my_slice, local_emph_idx .. local_emph_idx
      end

      def __render_this_syntax stx, em_range

        st = stx.to_argument_stream
        arg = st.gets

        if arg

          y = []
          d = 0
          begin
            s = __render_arg_text arg
            if em_range.include? d
              s = @_expression.expression_agent.calculate do
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

      def __render_arg_text arg

        _, ___ = Here_::Syntax_Assembly.brackets_for_reqity_ arg.reqity_symbol_

        __ = @_expression.expression_agent.calculate do
          render_property_as_argument arg
        end

        "#{ _ }#{ __ }#{ ___ }"
      end
    end
  end
end

# :#tombstone: eulogy for HUGE [hl] action instance methods (large)
