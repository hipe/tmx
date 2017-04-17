module Skylab::Treemap

  class Output_Adapters_::GroupBySigil

    # (this is a one-off for debugging a strange case,
    # as well as being a frontier-pusher for the new [tr].)

    def initialize o, & p
      @_oes_p = p
      @_sout = o.stdout_
    end

    def required_stream
      :leaf_stream
    end

    attr_writer :leaf_stream

    def execute

      branch_a = nil
      branch_number_stack = nil
      build_branch_stack_for = nil
      depth_index = nil
      do_stay = true
      down = @_sout
      number_of_sigil_changes = 0
      number_of_tests = 0
      number_of_tests_under_current_sigil = nil
      o = nil
      result_x = nil
      sigil = nil
      sigil_change = nil
      sigil_rx = /(?<=\A)\[[^\]]+\]/
      tick = nil
      top_branch = nil

      when_failed_to_match_sigil = nil

      subsequent_p = nil
      p = -> do
        p = nil  # sanity

        depth_index = o.depth_index

        branch_a = @_branch_cache

        branch_number_stack = build_branch_stack_for[ o ]

        top_branch = branch_a.fetch branch_number_stack[ 1 ]

        md = sigil_rx.match top_branch.content
        if md
          number_of_sigil_changes += 1
          sigil = md[ 0 ]
          number_of_tests_under_current_sigil = 1
          down.write "#{ sigil }#{ TEST_GLYPH__ }"
          p = subsequent_p
        else
          when_failed_to_match_sigil[ top_branch ]
        end
        NIL_
      end

      subsequent_p = -> do

        # this current leaf node is sibling to the previous one IFF they
        # are at the same depth and have the same parent

        same_parent_ = if depth_index == o.depth_index

          branch_number_stack.last == o.parent_branch_number
        end

        if same_parent_

          tick[]

        else

          # whether this node is deeper or shallower than the previous one,
          # the only common parent node it has for sure is the root node.
          # find the common parent:

          bs_ = build_branch_stack_for[ o ]

          idx_ = Home_.lib_.basic::List.index_of_deepest_common_element(
            branch_number_stack,
            bs_ )

          # if the common parent is at index 1 or greater, we are certainly
          # under the same sigil. otherwise, it *might* mean a sigil change.

          if idx_.zero?

            # a common index of zero means that only the root node is common

            top_branch_ = branch_a.fetch( bs_.fetch 1 )

            md = sigil_rx.match top_branch_.content
            if md
              ok_ = true
              sigil_ = md[ 0 ]
              sigil_is_same_ = sigil == sigil_
            else
              when_failed_to_match_sigil[ top_branch_ ]
              ok_ = false
            end
          else
            sigil_is_same_ = true
            ok_ = true
          end

          if ok_
            if sigil_is_same_
              branch_number_stack = bs_
              depth_index = o.depth_index
              tick[]
            else
              sigil_change[ sigil_, bs_, top_branch_ ]
            end
          end
        end

        NIL_
      end

      build_branch_stack_for = -> o_ do

        _st_ = o_.to_parent_stream_around branch_a

        a_ = _st_.map_by do | o__ |
          o__.branch_number
        end.to_a

        a_.reverse!
        a_
      end

      sigil_change = -> sigil_, bs_, top_branch_ do

        number_of_tests += number_of_tests_under_current_sigil

        down.write(
          "(#{ number_of_tests_under_current_sigil })\n#{
           }#{ sigil_ }" )

        number_of_sigil_changes += 1
        sigil = sigil_

        number_of_tests_under_current_sigil = 0

        tick[]

        branch_number_stack = bs_
        depth_index = o.depth_index
        NIL_
      end

      summarize = -> do  # (halfway like a sigil change)

        if number_of_tests_under_current_sigil

          down.puts "(#{ number_of_tests_under_current_sigil })"

          number_of_tests += number_of_tests_under_current_sigil
        end

        down.puts "(#{ number_of_tests } tests over #{
          }#{ number_of_sigil_changes } sigil change#{
          }#{ 's' if 1 != number_of_sigil_changes })"

        result_x = ACHIEVED_
      end

      tick = -> do
        number_of_tests_under_current_sigil += 1
        down.write TEST_GLYPH__
        NIL_
      end

      when_failed_to_match_sigil = -> o_ do

        @_oes_p.call :error, :expression do | y |
          y << "failed to match sigil on line #{ o_.lineno }:"
          y << o_.content.inspect
        end

        do_stay = false
        result_x = UNABLE_

        NIL_
      end

      o_st = @leaf_stream
      begin

        o = o_st.gets
        if o
          p[]
        else
          do_stay = false
          summarize[]
        end
        if do_stay
          redo
        end
        break
      end while nil

      result_x
    end

    TEST_GLYPH__ = '.'

    def maybe_receive_event_on_channel i_a, & ev_p

      if :info == i_a.first && :data == i_a[ 1 ]
        send :"__receive__#{ i_a.last }__", ev_p[]
      else
        @_oes_p.call( * i_a, & ev_p )
      end
    end

    def __receive__branch_cache_array__ o

      @_branch_cache = o
      NIL_
    end
  end
end
