module Skylab::TestSupport

  module Permute  # :[#045].

    module API ; class << self

      def call * x_a, & p
        Zerk_lib_[]
        _acs = Root_Autonomous_Component_System.__instance
        Zerk_::API.call( x_a, _acs ) { |_| p }
      end
    end ; end

    class Root_Autonomous_Component_System  # (accessed by our host, [ts])

      class << self

        def __instance
          @___instance ||= via_filesystem_by { Home_.lib_.system.filesystem }
        end

        def via_filesystem_by & fs_p
          new fs_p
        end

        private :new
      end  # >>

      def initialize fs_p
        @_filesystem_proc = fs_p
      end

      def __ping__component_operation

        -> &p do

          p.call :info, :expression, :ping do |y|
            y << "ping from permute."
          end
          NOTHING_
        end
      end

      def __permute__component_operation

        yield :via_ACS_by, -> do
          Permute_Operation___.new @_filesystem_proc
        end
      end
    end

    class Permute_Operation___  # :[#045].

      def initialize fs_p
        @_filesystem_proc = fs_p
      end

      def self.describe_into_under y, expag
        y << "generate stub tests given a collection of categories"
      end

      if false
        hi(
          :inflect,
            :verb, 'permute',
            :noun, 'test document',
            :verb_as_noun, 'permutation',
        )
      end

      def __permutations__component_association
        -> st do
          Common_::KnownKnown[ st.gets_one ]
        end
      end

      def __test_file__component_association

        yield :description, -> y do
          y << "(the test file yadda)"
        end

        -> st, & pp do

          _x = st.gets_one
          _kn = Common_::QualifiedKnownKnown.via_value_and_symbol _x, :test_file
          _p = pp[ nil ]

          _real_FS = @_filesystem_proc.call

          _kn = Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(
            :qualified_knownness_of_path, _kn,
            :filesystem, _real_FS,
            & _p )

          _kn
        end
      end

      def execute & p
        @_on_event_selectively = p
        extend Permutations_Implementation___
        execute
      end
    end
    # -
      module Permutations_Implementation___

        def execute
          @_down = Puts_Proxy___.new
          ok = true
          ok &&= __index_existing_lines
          ok &&= __rewind_and_ouput_beginning_while_looking_for_mentor
          ok &&= __via_mentor_advance_to_end_of_this_test
          ok &&= __via_pairs_make_that_money
          ok && __output_the_rest_and_finish
        end

        def __index_existing_lines

          # before we write anything, we have to know
          # what cases are already there

          up = @test_file

          st = Common_.stream do
            up.gets
          end.map_reduce_by do | line |

            Models_::Line_Matchdata.any_via_line line
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

          @test_file.rewind
          begin
            line = @test_file.gets
            line or break
            @_down.puts line
            match = Models_::Line_Matchdata.any_via_line line
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
            line = @test_file.gets
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

          case_string_st = @permutations.map_by do |tuple|

            tuple.values.join sep
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
            down.puts "#{ margin }  ::Kernel._WRITE_ME"
            down.puts "#{ margin }end"
            NIL_
          end
        end

        def __output_the_rest_and_finish

          begin
            line = @test_file.gets
            line or break
            @_down.puts line
            redo
          end while nil

          o = @_counts
          d = o.number_already_done
          if d.nonzero?
            _extra = ", #{ d } already done"
          end

          @_on_event_selectively.call :info, :expression, :summary do |y|
            y << "(#{ o.number_added } case(s) added#{ _extra })"
          end

          _lines = remove_instance_variable( :@_down )._a
          Stream_[ _lines ]
        end

        Counts___ = ::Struct.new :number_added, :number_already_done

        Models_ = ::Module.new

        class Puts_Proxy___  # surpsingly we didn't see another like this

          # #[#sy-039.1] one of many such proxies

          def initialize
            @_a = []
          end
          def puts line
            if LOOKS_LIKE_LINE_RX___ !~ line
              line = "#{ line }#{ NEWLINE_ }"
            end
            @_a.push line ; nil
          end
          attr_reader(
            :_a,
          )
        end

        LOOKS_LIKE_LINE_RX___ = /[\n\r]\z/

        class Models_::Line_Matchdata

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

        # #todo (the big kahuna instead of the below hack)

        IT_RX__ = /\A
          (?<margin> [ \t]* )
          it[ ](?:

            "    (?<inside>  [^"]+  ) "
            |
            '    (?<inside>  [^']+  ) '
            |
            %\{  (?<inside>  [^}]+  )  \}
          )
          [ ] do
        $/x

        # of "foo - bar - baz"..

        # CASE_RX__ = /.*(?= - (?:(?! - ).)+\z)/  # match longest  ("foo - bar")

        CASE_RX__ = /(?:(?! - ).)+(?= - .+\z)/  # match shortest ("foo")
      end
    # -
  end
end
# #tombstone: pre-zerk
