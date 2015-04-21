module Skylab::Snag

  module Models_::Criteria

    module Library_

      # library (local & iternal) name conventions:
      #
      #   • `interpret_` takes a in_st and a g.ctxt. result is o.n
      #
      #   • `output_node_via_input_stream` is a strong idiom from vendor
      #
      #   • `scan_` like the others but result is trueish e.g an integer
      #
      #   • `parse_` when none of the above. result is an o.n

      # ~ models & like

      Methodic_ = Callback_::Actor.methodic_lib

      class Common_Adapter_

        include Methodic_.iambic_processing_instance_methods

        def process_iambic_stream_fully st
          _ok = super
          _ok && via_default_proc_and_is_required_normalize
        end
      end

      class Grammatical_Context_

        extend Actor_as_Model_Module_Methods_

        Callback_::Actor.call self, :properties, :subject_number  # see the top of Pos::Verb

        attr_reader :subject_number

        def initialize
          super
          freeze
        end
      end

      # ~ parse functions

      # ~~ parse functions for syntactic structures

      Parse_a_conjunction_ = -> do
        p = -> x do

          p_ = Build_simple_word_parser_[ :or, :keyword, 'or',
                                         :and, :keyword, 'and' ]

          p = -> in_st do
            o = p_[ in_st ]
            o and o.name_symbol
          end

          p[ x ]
        end
        -> x do
          p[ x ]
        end
      end.call

      # ~~ parse functions - mechanisms

      Parse_first_match_via_box_ = -> in_st, bx, id_x do

        h = bx.h_
        sym, obj = bx.a_.reduce nil do | _, k |

          x = h.fetch( k ).output_node_via_input_stream in_st
          if x
            break [ k, x ]
          end
        end

        if sym

          Library_::Models_::Name_Value_Output_Node.new obj.value_x, sym, id_x
        end
      end

      Parse_highest_scoring_candidate_ = -> in_st, ada_st, oes_p, & on_p do

        # ( :+#abstraction-candidate would become [#mh-003] )

        cand_a = Produce_highest_scoring_candidates_[
          in_st, ada_st, oes_p, & on_p ]

        case 1 <=> cand_a.length
        when 0
          cand = cand_a.fetch 0
          in_st.current_index = cand.distance
          cand
        when 1
          # errors were emitted by callee
          UNABLE_
        when -1
          self._YAY_AMBIGUITY
        end
      end

      Produce_highest_scoring_candidates_ = -> in_st, ada_st, oes_p, & on_p do

        d = in_st.current_index
        e_a = nil
        cand_a = []
        max = 0

        cache_expectations = if oes_p
          -> * i_a, & ev_p do
            e_a ||= []
            e_a.push [ i_a, ev_p ]
            UNABLE_
          end
        end

        begin

          f = ada_st.gets
          f or break

          on = on_p[ in_st, f, & cache_expectations ]

          if ! on
            redo
          end

          score = in_st.current_index
          if max < score
            max = score
          end

          cand_a.push Candidate___.new( in_st.current_index, on, f )
          in_st.current_index = d

          redo
        end while nil

        if cand_a.length.zero?

          if e_a  # near [#012]
            e_a.each do | i_a_, ev_p_ |
              oes_p.call( * i_a_, & ev_p_ )
            end
          end

        else
          cand_a.sort_by!( & :distance )
          d = ( cand_a.length - 1 ).downto( 0 ).detect do | d_ |
            max != cand_a.fetch( d_ ).distance
          end
          if d
            cand_a[ 0 .. d ] = EMPTY_A_
          end
        end

        cand_a
      end

      Candidate___ = ::Struct.new :distance, :output_node, :adapter

      Parse_static_sequence_ = -> in_st, s_a, & oes_p do

        # ~ :+#abstraction-candidate [#mh-004]

        d = in_st.current_index
        d_ = 0
        last = s_a.length - 1

        begin

          s = s_a.fetch d_
          if in_st.no_unparsed_exists  # reached end of input prematurely

            if oes_p
              d__ = in_st.current_index
              oes_p.call :error, :expecting do

                Expecting_[ d__, s, in_st ]
              end
            end
            break
          end

          _s_ = in_st.current_token

          if s != _s_  # if doesn't match at this column, we are done.

            if oes_p
              d__ = in_st.current_index
              oes_p.call :error, :expecting do

                Expecting_[ d__, s, in_st ]
              end
            end
            break
          end

          if last == d_  # got to the end of our target sequence. success.
            did_match = true
            break
          end

          d_ += 1
          in_st.advance_one
          redo

        end while nil

        if did_match
          in_st.advance_one
        else
          in_st.current_index = d
        end

        did_match
      end

      Build_simple_word_parser_ = -> * x_a do

        last = x_a.length - 3

        -> in_st, & oes_p do

          if in_st.unparsed_exists

            d = 0
            s = in_st.current_token

            begin

              case x_a.fetch( d + 1 )
              when :keyword
                if x_a.fetch( d + 2 ) == s
                  did_match = true
                  x = Callback_::Pair.new true, x_a.fetch( d )
                  break
                end

              when :regex
                md = x_a.fetch( d + 2 ).match s
                if md
                  did_match = true
                  x = Callback_::Pair.new md, x_a.fetch( d )
                  break
                end
              end

              if last == d
                break
              end
              d += 3
              redo
            end while nil

            if did_match
              in_st.advance_one
              x
            elsif oes_p
              self._FUN_AND_EASY  # near [#012]
            end
          end
        end
      end

      # ~~ parse functions - building expecting events

      Build_aggregated_expecting_event_ = -> pairs do

        idx_bx = Callback_::Box.new
        word_bx = Callback_::Box.new

        pairs.each_slice 2 do | i_a, ev_p |
          :expecting == i_a.last or self._XX

          ev = ev_p[]

          ev.input_stream_indexes.each do | d |
            idx_bx.touch d do true end
          end

          ev.word_s_a.each do | s |
            word_bx.touch s do true end
          end
        end

        Expecting_[ idx_bx.a_, word_bx.a_, @in_st ]
      end

      Expecting_ = -> do

        p = -> index_x, word_x, in_st do

          Event_for_Expecting___ = Callback_::Event.prototype_with :expecting,
              :word_s_a, nil,
              :input_stream_indexes, nil,
              :input_stream, nil,
              :error_category, :argument_error,
              :ok, false

          p = -> idx_x_, word_x_, in_st_ do

            _idx_a = ::Array.try_convert( idx_x_ ) || [ idx_x_ ]
            _word_a = ::Array.try_convert( word_x_ ) || [ word_x_ ]

            Event_for_Expecting___.new_with(
              :input_stream_indexes, _idx_a,
              :word_s_a, _word_a,
              :input_stream, in_st_
            )
          end

          p[ index_x, word_x, in_st ]
        end

        -> index_x, word_x, in_st do
          p[ index_x, word_x, in_st ]
        end
      end.call

      # ~

      DID_NOT_PARSE_ = nil
      Library_ = self  # future proof the name, avoid mis-accessing super
      LIB_ = Snag_.lib_
      NEWLINE_ = "\n"
    end
  end
end
