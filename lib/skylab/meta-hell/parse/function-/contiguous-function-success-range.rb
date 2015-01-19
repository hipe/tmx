module Skylab::MetaHell

  module Parse

    module Function_

      class Contiguous_Function_Success_Range < Parse_::Function_::Field

        class << self

          # ~ for creating the subclass:

          alias_method :orig_new, :new

          def new min, max

            min ||= 0
            max ||= -1

            _parent_class = if 0 == max || 1 == max
              Monadic_Upper_Bounds__
            else
              Polyadic_Upper_Bounds__
            end

            ::Class.new _parent_class do

              const_set :MIN__, min
              const_set :MAX__, max

            end
          end
        end  # >>

        # ~ for construction:

        def process_iambic_stream_passively st  # #hook-in to [cb] actor construction

          # we need at least and at most one parse function.

          f = Parse_.function_( st.gets_one ).new_via_iambic_stream_passively( st )
          f and begin
            @f = f
            KEEP_PARSING_
          end
        end

        def initialize
          @is_first_parse = true
          super
        end

        # ~ for parse:

        def output_node_via_input_stream in_st
          if @is_first_parse
            dup._init_for_parse( in_st ).parse_
          else
            _output_node_as_packrat
          end
        end

        class Monadic_Upper_Bounds__ < self

          class << self
            alias_method :new, :orig_new
          end

          def _init_for_parse in_st
            super
            @num_times_succeeded_hit_MAX = build_bound_max_check_
            @output_value_x = nil
            self
          end

          def _accept_output_node on
            @output_value_x = on.value_x
            nil
          end

          def _output_node_as_packrat

            # a re-parse for the monadic function is always for the zero-width case

            Parse_::Output_Node_.the_empty_node
          end

          def _flush  # assume num times succeeded satisifes min

            ov_x = @output_value_x  # is nil when an optional range didn't match

            if @max_for_first_packrat_parse
              _become_first_next_try
              _try_next = self
            end

            Parse_::Output_Node_.new_with ov_x, :try_next, _try_next
          end

          def _become_first_next_try
            super
            @max = @max_for_first_packrat_parse
            @max_for_first_packrat_parse = nil
            nil
          end
        end

        class Polyadic_Upper_Bounds__ < self

          class << self
            alias_method :new, :orig_new
          end

          def _init_for_parse in_st
            super

            @long_running_mutable_output_node = Parse_::Output_Node_.new(
              @mutable_outout_value_x_a = [] )

            @num_times_succeeded_hit_MAX = if -1 == @max
              EMPTY_P_
            else
              build_bound_max_check_
            end

            self
          end

          def _accept_output_node on
            @mutable_outout_value_x_a.push on.value_x
            nil
          end

          def _flush

            if @max_for_first_packrat_parse

              @is_first_parse or self._SANITY

              _become_first_next_try

              @max = @max_for_first_packrat_parse
              @max_for_first_packrat_parse = nil
            end

            @long_running_mutable_output_node
          end

          def _become_first_next_try

            super

            if -1 == @max
              @num_times_succeeded_hit_MAX = build_bound_max_check_
            end

            @long_running_mutable_output_node.mutate_try_next_ self

            nil
          end

          def _output_node_as_packrat

            # you are here because you are a polyadic node that has passed
            # itself as a "try-again" "re-parse", and the re-parse is being
            # requested. such a re-parse is always a backtrack by one
            # grammatical item (not input token). use your already-adjusted
            # new `@max` value to shrink your output value array appropriately
            # and set the input stream's index to where it "should" be by
            # looking it up in your waypoints list.

            @mutable_outout_value_x_a[ @max .. -1 ] = EMPTY_A_

            # a max of zero means "set the input scanner to what it was
            # when we first started our first parse", i.e the first waypoint.
            # a max of one means "set the input scanner to what it was
            # immediately *after* we successfully scanned our first item",
            # i.e the second waypoint (i.e index 1); and so on.

            @input_stream.current_index = @waypoints.fetch @max

            if @min == @max

              # when you have backtracked back to the beginning of your range,
              # then this is the last backtrack - you won't be presenting an
              # object (which had happened to be yourself) as a "try again"
              # object any more.

              @long_running_mutable_output_node.mutate_try_next_ nil

            else

              # for the next try, your result will be with one
              # less grammatical item than you had this try

              @max -= 1
            end

            @long_running_mutable_output_node
          end
        end

        def _init_for_parse in_st

          # ~ these ivars persist from first parse to subsequent re-parse:

          @input_stream = in_st

          @min = self.class::MIN__

          @num_times_succeeded_satisfies_MIN = -> do
            @min <= @num_times_succeeded
          end

          # ~ these ivars may change between parses:

          @max = self.class::MAX__

          @max_for_first_packrat_parse = nil

          nil
        end

        def parse_

          @num_times_succeeded = 0

          @waypoints = [ @input_stream.current_index ]

          begin

            if @num_times_succeeded_hit_MAX[]
              x = _flush
              break
            end

            on = @f.output_node_via_input_stream @input_stream

            if on
              @waypoints.push @input_stream.current_index

              if @num_times_succeeded_satisfies_MIN[]
                @max_for_first_packrat_parse = @num_times_succeeded
              end

              @num_times_succeeded += 1

              _accept_output_node on

              redo

            else

              if @num_times_succeeded_satisfies_MIN[]
                x = _flush
              end

              break
            end

          end while nil
          x
        end

        def _become_first_next_try

          @input_index_for_try_again = @waypoints.fetch 0

          @is_first_parse = false

          nil
        end

        attr_reader :input_index_for_try_again

        def build_bound_max_check_
          -> do
            @max == @num_times_succeeded
          end
        end
      end
    end
  end
end
