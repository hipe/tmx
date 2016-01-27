module Skylab::Autonomous_Component_System

  module Modalities::Human

    class Contextualized_Expression  # #[#021] (blind, dumb, better rewrite)

      attr_writer(
        :context_linked_list,
        :expression_agent,
        :expression_proc,
        :say_association,
        :subject_association,
        :upstream_line_yielder,
      )

      def execute

        # only on the first line of the component-
        # provided emission, qualify it:

        expag = @expression_agent
        ev_p = @expression_proc
        y = @upstream_line_yielder

        p = -> ss do
          p = -> s do
            y << s ; nil
          end
          ___express_contextualized_first_line ss
          NIL_
        end

        _my_y = ::Enumerator::Yielder.new do |s|
          p[s]
        end

        expag.calculate _my_y, & ev_p

        y
      end

      def ___express_contextualized_first_line component_expression_s

        say = @say_association
        asc = @subject_association
        expag = @expression_agent
        _LL = @context_linked_list
        y = @upstream_line_yielder

        s_a = []
        st = _LL.to_element_stream_assuming_nonsparse
        begin
          p = st.gets
          p or break
          _hi = expag.calculate( & p )
          s_a.push _hi
          redo
        end while nil

        # `s_a` => [ .. "in sub-thing", "in root thing" ]

        _ = Home_.lib_.basic::String
        bef, pred, aft = _.unparenthesize_message_string component_expression_s

        s = say[ asc ]
        if s
          _pre_ctx = "#{ s } "
        end

        if s_a.length.nonzero?
          _post_ctx = " #{ s_a.join SPACE_ }"
        end

        y << "#{ bef }#{ _pre_ctx }#{ pred }#{ _post_ctx }#{ aft }"
        NIL_
      end
    end
  end
end
