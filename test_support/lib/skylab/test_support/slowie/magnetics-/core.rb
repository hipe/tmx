module Skylab::TestSupport

  class Slowie

    Magnetics_ = ::Module.new

      if false
      # this plugin is not activated by use of input arguments - it passively
      # makes these state traversals if no other plugin does.

      can :build_sidesystem_tree

      can :build_the_test_files do | tr |

        tr.if_transition_is_effected do | o |

          o.on '-v', '--verbose', 'increase verbosity (2 gives you huge dump)' do
            @verbosity += 1 ; nil
          end
        end
      end

      def initialize( * )
        super
        @bx = nil
        @verbosity = 0
        @white_a = nil
      end

      # ~ building the sidesystem tree

      def do__build_sidesystem_tree__

        p = @on_event_selectively.call :for_plugin, :sidesystem_stream_proc

        p and __build_sidesystem_tree p
      end

      def __build_sidesystem_tree p

        @on_event_selectively.call :from_plugin, :sidesystem_box do

          bx = Common_::Box.new

          st = p[]
          while lt = st.gets
            bx.add lt.stem, lt
          end

          @bx = bx

          if @white_a
            __reduce_via_whitelist
          else
            bx
          end
        end
      end

      # ~ finding the test files

      def do__build_the_test_files__

        # strange but true: we don't succeed unless the dispatcher receives is

        ok = false

        @on_event_selectively.call :from_plugin, :test_file_stream do

          st = __build_stream_of_test_files
          ok = st ? ACHIEVED_ : st
          st
        end

        ok
      end

      def __build_stream_of_test_files

        # NOTE FROM THE PRESENT - this method is almost surely now or will
        # be soon obviated by the "globber" model, but is here for reference
        # for now..

        # in a stark reversal of the algorithm of our predecessor, we find
        # the test files on-demand once per sidesystem..

        # the list of paths we pass to `find` must all exist, so first we
        # find all sidesystems that have a test directory:

        st = __build_stream_of_test_directories

        proto = __build_find_test_files_prototype  # moved

        base_p = p = -> do  # write our own map-expand stream

          test_directory_path = st.gets

          if test_directory_path

            _find = proto.new_with :path, test_directory_path

            st_ = _find.to_path_stream

            p = -> do

              path = st_.gets
              if path
                path
              else
                p = base_p
                base_p[]
              end
            end
            p[]

          else
            p = EMPTY_P_ ; nil
          end
        end

        Common_.stream do
          p[]
        end
      end

      def __build_stream_of_test_directories

        # now that we base our collection off of installed gems (and not a
        # top-of-the-universe directory), we assume that per convention,
        # *every* gem has a test directory. (we used to call `find`!)

        # because of The Graph, if we have gotten this far we are "certain"
        # the box exists

        if @bx
          _stream @bx
        elsif @white_a
          @resources.serr.puts "(cannot process whitelist with this source)"
          UNABLE_
        else
          _bx = @on_event_selectively.call :for_plugin, :sidesystem_box
          _stream _bx
        end
      end

      def _stream bx

        tail = Home_::Init.test_directory_entry_name

        bx.to_value_stream.map_by do |lt|

          ::File.join lt.gem_path, tail
        end
      end

      # ~ whitelisting sidesystems

      def description_for_ARGV_syntax_under expag
        s = expag.calculate do
          par 'subsystem'
        end
        "[#{ s } [#{ s } [..]]]"
      end

      def process_ARGV argv
        if argv.length.nonzero?
          __process_nonzero_length_ARGV argv
        else
          ACHIEVED_
        end
      end

      def __process_nonzero_length_ARGV argv

        d = 0 ; len = argv.length
        a = []
        until len == d
          token = argv.fetch d
          DOUBLE_DASH__ == token and break
            # (currently optparse removes dashes anyway so the above is never
            #  engaged, but it is left intact in case we figure this out)
          a.push token
          d += 1
        end
        if len.nonzero?
          if len == d
            argv.clear
          else
            argv[ 0 .. d ] = EMPTY_A_
          end
        end
        @white_a = a
        ACHIEVED_
      end

      DOUBLE_DASH__ = '--'.freeze

      def __reduce_via_whitelist

        # fuzzy matching is the exception not the rule implementation-wise.
        # we first try the mechanically simpler exact matching below before
        # engaging the complexity that follows.

        match_a = ::Array.new @white_a.length

        remaining_exact_h = {}

        @white_a.each_with_index do | s, d |
          match_a[ d ] = Matcher___.new( [], d, s )
          remaining_exact_h[ s ] = d
        end

        @bx.a_.each do | s |

          match_idx = remaining_exact_h.delete s
          match_idx or next
          match_a.fetch( match_idx ).matched_against_s_a.push s

        end

        # the results box's items will have an order corresponding
        # to the matching expressions, not the input box

        if remaining_exact_h.length.nonzero?

          # since we want to detect variously whether each matcher is never
          # used (matching zero) or ambiguous (matching more than one), we've
          # got to check every remaining matcher against every remaining item
          # (N^2); there is no "diminishing pool" (early short-circuit) here.

          passed_h = {}
          every_remaining_matcher = match_a.reduce [] do | m, mtchr |

            if remaining_exact_h[ mtchr.s ]
              mtchr.rx = /\A#{ ::Regexp.escape mtchr.s }/
              m.push mtchr
            else
              passed_h[ mtchr.s ] = true
            end
            m
          end

          @bx.a_.each do |s|

            passed_h[ s ] and next

            every_remaining_matcher.each do | mtch |
              mtch.rx =~ s or next
              mtch.matched_against_s_a.push s
            end
          end

          no_matches = nil ; ambi = nil

          every_remaining_matcher.each do | mtch |
            case 1 <=> mtch.matched_against_s_a.length
            when  0
              passed_h[ mtch.matched_against_s_a.first ] = true
            when -1
              ( ambi ||= [] ).push mtch
            else
              ( no_matches ||= [] ).push mtch
            end
          end
        end

        if ambi || no_matches
          __when_ambiguous_or_unused_fuzzy_matchers ambi, no_matches
        else
          __flush_reduced_box match_a
        end
      end

      def __when_ambiguous_or_unused_fuzzy_matchers ambi, no_matches

        if no_matches

          @on_event_selectively.call :error, :expression, :didnt_match_anything do | y |

            a = no_matches.map do | mtch |
              ick mtch.s
            end

            y << "#{ sp_(
              :subject, a, :negative, :verb, 'match', :object, 'subsystem'
            ) }."
              # e.g. "X and Y do not match any subsystems."

            NIL_
          end
        end

        if ambi

          @on_event_selectively.call :error, :expression, :ambiguous_fuzzy_matches do | y |

            ambi.each do | mtch |

              _s_a = mtch.matched_against_s_a.map do | s |
                val s
              end
              y << "#{ ick mtch.s } is too ambiguous: it matches against #{ and_ _s_a }"

            end
          end
        end

        UNABLE_
      end

      Matcher___ = ::Struct.new :matched_against_s_a, :index, :s, :rx

      def __flush_reduced_box match_a

        h = @bx.h_

        bx = Common_::Box.new

        match_a.each do | match |

          s = match.matched_against_s_a.fetch( 0 )
          bx.add s, h.fetch( s )
        end

        @bx = bx
        bx
      end
      end  # if false

  end
end
