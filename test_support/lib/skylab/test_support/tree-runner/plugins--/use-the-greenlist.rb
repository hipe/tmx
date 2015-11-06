module Skylab::TestSupport

  class Tree_Runner

    class Plugins__::Use_the_GREENLIST < Plugin_

      GREENLIST_path___ = -> do

        _path = Home_.lib_.slicer.data_documents_path

        ::File.join _path, 'GREENLIST'
      end

      does :build_sidesystem_tree do | tr |

        tr.transition_is_effected_by do | o |

          o.on(
            '--greenlist [args]',
            "syntax: --greenlist [ NUM_A [ ORD NUM_B | NUM_B ORD ] ]",
            "without arguments, show the greenlist and hackishly stop",
            "NUM_A is the line number to run from the greenlist",
            "optinal NUM_B and ORD select items to run from that line",
            "NUM_B is the \"chunk size\" and ORD is the offset",
            "for example, to do the first three items from line two:",
            "    --greenlist two first three"
          ) do  | tok |

            if tok
              argv = @resources.argv
              argv.unshift tok  # life is easier
              @_do_display = false
              __parse argv
            else
              @_do_display = true
            end
            NIL_
          end
        end
      end

      def do__build_sidesystem_tree__
        if @_do_display
          __express_info
        else
          __do_etc
        end
      end

      def __express_info
        io = _produce_GREENLIST_IO
        serr = @resources.serr
        serr.puts "(greenlist path: #{ io.path })"
        while line = io.gets
          line.chomp!
          serr.puts "(greenlist line: #{ line })"
        end
        NIL_
      end

      def __parse argv

        # only because such commands will in practice need to be parsed
        # max once per runtime do we build the parser here knowing this

        _Parse = Home_.lib_.parse
        opn = _Parse.output_node
        pair = -> x, sym do
          Callback_::Pair.via_value_and_name x, sym
        end

        en_num_rx = /\A(?:
          (one)|(two)|(three)|(four)|(five)|(six)  # etc
        )\z/x

        easy_num_rx = /\A(?<digits>[0-9]+)\z/

        some_number = -> st do

          s = st.current_token
          md = en_num_rx.match s
          if md
            d = _integer_via_matchdata md
          else
            md = easy_num_rx.match s
            if md
              d = md[ :digits ].to_i
            end
          end
          if d
            st.advance_one
            opn.new pair[ d, :num ]
          end
        end

        en_ord_rx = /\A(?:
          (first)|(second)|(third)|(fourth)|(fifth)|(sixth)  # etc
        )\z/x

        easy_ord_rx = /\A(?<digits>[0-9]+)(?:st|nd|rd|th)\z/

        some_ord = -> st do

          s = st.current_token
          md = en_ord_rx.match s
          if md
            d = _integer_via_matchdata md
          else
            md = easy_ord_rx.match s
            if md
              d = md[ :digits ].to_i
            end
          end
          if d
            st.advance_one
            opn.new pair[ d, :ord ]
          end
        end

        soften = -> p do
          -> st do
            if st.unparsed_exists
              p[ st ]
            end
          end
        end

        number = soften[ some_number ]
        ord = soften[ some_ord ]

        _pf = _Parse.function( :sequence ).new_with( :functions,
          :proc, number,
          :zero_or_one,
            :alternation, :functions,
              :sequence, :functions,
                :proc, ord,
                :proc, number,
                :end_functions,
              :sequence, :functions,
                :proc, number,
                :proc, ord,
                :end_functions,
              :end_functions,
          :zero_or_one, :keyword, 'show'
        )

        st = _Parse.input_stream.via_array argv

        output = _pf.output_node_via_input_stream st
        if output

          argv[ 0, st.current_index ] = EMPTY_A_
          @__parse_tree = output.value_x

        else
          self._COVER_ME
        end

        NIL_
      end

      def _integer_via_matchdata md

        ( 1..10 ).detect do | d |
          md[ d ]
        end
      end

      def __do_etc

        io = _produce_GREENLIST_IO

        pt = remove_instance_variable :@__parse_tree

        line = nil

        thing, opt, do_show = pt

        thing.value_x.times do
          ( line = io.gets ).chomp!
        end
        io.close

        s_a = line.split %r([[:space:]]+)
        if opt
          if :num == opt.first.name_x
            opt.reverse!
          end
          ord, num = opt

          chomp_size = num.value_x

          _factor = ord.value_x - 1  # first=0, second=1 etc

          s_a = s_a[ _factor * chomp_size, chomp_size ]
        end

        if do_show
          @resources.sout.puts s_a * SPACE_
          NIL_
        else
          __run_them s_a
        end
      end

      def __run_them s_a

        @resources.serr.puts "(#{ s_a * SPACE_ })"

        bx = Callback_::Box.new

        _TMX = Home_.lib_.TMX

        s_a.each do | sidesys_s |

          bx.add sidesys_s, _TMX.lookup_sidesystem( sidesys_s )
        end

        @on_event_selectively.call :from_plugin, :sidesystem_box do
          bx
        end

        ACHIEVED_
      end

      def _produce_GREENLIST_IO
        ::File.open GREENLIST_path___[], ::File::RDONLY
      end
    end
  end
end
