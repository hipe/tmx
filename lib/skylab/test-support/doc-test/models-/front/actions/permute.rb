module Skylab::TestSupport

  module DocTest

    module Models_::Front

      class Actions::Permute < Action_  # :[#045].

        edit_entity_class(

          :promote_action,

          :desc, -> y do
            y << "magnets HACK"
          end,

          :inflect,
            :verb, 'permute',
            :noun, 'test document',
            :verb_as_noun, 'permutation',

          :required, :property, :permutations,

          :required, :property, :stdout,
          :required, :property, :stderr,

          :required, :property, :test_file
        )

        def produce_result

          ok = __resolve_upstream_IO
          ok &&= __index_existing_lines
          ok &&= __rewind_and_ouput_beginning_while_looking_for_mentor
          ok &&= __via_mentor_advance_to_end_of_this_test
          ok &&= __via_pairs_make_that_money
          ok && __output_the_rest_and_finish
        end

        def __resolve_upstream_IO

          io =
          Home_.lib_.system.filesystem.normalization.upstream_IO.with(
            :path_arg, knownness( :test_file ),
            & handle_event_selectively )

          if io

            h = @argument_box.h_

            @_down = h.fetch :stdout
            @_thru = h.fetch :stderr
            @_up = io

            ACHIEVED_
          else
            io
          end
        end

        def __index_existing_lines

          # before we write anything, we have to know
          # what cases are already there

          up = @_up

          st = Callback_.stream do
            up.gets
          end.map_reduce_by do | line |

            Line_Matchdata__.any_via_line line
          end

          seen_h = {}

          match = st.gets
          if match
            @_mentor = match

            seen_h[ match.case_string ] = true

            begin
              match = st.gets
              match or break
              seen_h[ match.case_string ] = true
              redo
            end while nil

            @_seen_h = seen_h

            ACHIEVED_
          else
            self._TODO
          end
        end

        def __rewind_and_ouput_beginning_while_looking_for_mentor

          @_up.rewind
          begin
            line = @_up.gets
            line or break
            @_down.puts line
            match = Line_Matchdata__.any_via_line line
            if match
              break
            end
            redo
          end while nil

          if match
            @_mentor = match
            ACHIEVED_
          else
            self._TODO_when_found_no_mentor
          end
        end

        def __via_mentor_advance_to_end_of_this_test

          rx = /\A#{ ::Regexp.escape @_mentor.margin }end$/

          begin
            line = @_up.gets
            line or break
            @_down.puts line
            if rx =~ line
              break
            end
            redo
          end while nil

          if line
            ACHIEVED_
          else
            self._TODO_when_found_no_end
          end
        end

        def __via_pairs_make_that_money

          sep = ', '

          case_string_st = @argument_box.fetch( :permutations ).map_by do | perm |

            perm.values.join sep
          end

          counts = Counts___.new 0, 0

          express_template = __build_expressor

          begin
            case_s = case_string_st.gets
            case_s or break

            if @_seen_h[ case_s ]
              counts.number_already_done += 1
              redo
            end

            counts.number_added += 1

            @_down.puts EMPTY_S_

            express_template[ case_s ]

            redo
          end while nil

          @_counts = counts
          ACHIEVED_
        end

        def __build_expressor

          down = @_down
          mnt = @_mentor
          margin = mnt.margin

          -> case_s do

            down.puts "#{ margin }it \"#{ case_s }\" do"
            down.puts "#{ margin }  self._COVER_ME"
            down.puts "#{ margin }end"
            NIL_
          end
        end

        def __output_the_rest_and_finish

          begin
            line = @_up.gets
            line or break
            @_down.puts line
            redo
          end while nil

          o = @_counts
          d = o.number_already_done
          if d.nonzero?
            _extra = ", #{ d } already done"
          end
          @_thru.puts "(#{ o.number_added } case(s) added#{ _extra })"
          ACHIEVED_
        end

        Counts___ = ::Struct.new :number_added, :number_already_done

        class Line_Matchdata__

          class << self
            def any_via_line line

              md = IT_RX__.match line
              if md
                new md
              end
            end
          end  # >>

          def initialize md

            @_md = md
            md_ = CASE_RX__.match md[ :inside ]
            @_portion = if md_
              md_[ 0 ]
            end
          end

          def case_string
            @_portion || @_md[ :inside ]
          end

          def margin
            @_md[ :margin ]
          end
        end

        IT_RX__ = /\A
          (?<margin> [ \t]* )
          it[ ]"(?<inside>[^"]+)"[ ]do
        $/x

        # of "foo - bar - baz"..

        # CASE_RX__ = /.*(?= - (?:(?! - ).)+\z)/  # match longest  ("foo - bar")

        CASE_RX__ = /(?:(?! - ).)+(?= - .+\z)/  # match shortest ("foo")

      end
    end
  end
end
