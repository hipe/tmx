module Skylab::TestSupport

  module Regret

    module CLI

      class Expression_Agent_

        # a reconception of the pen. imagine accessibility and text to speech.
        # we have hopes for this to flourish upwards and outwards.
        # think of it as a proxy for that subset of your modality client that
        # does rendering. you then pass that proxy to the snitch, which is
        # passed throughout the application and is the central conduit though
        # which all expression is received and then articulated.

        RegretLib_::EN_add_methods[ self, :private, [ :and_, :or_, :s ] ]

        def initialize * x_a
          @client = Services__.new x_a
        end

        # a normal template string -
        #   "invalid #{ lbl x } value #{ ick x } - expecting #{ or_ a }"

        def lbl x
          x
        end

        def ick string
          "\"#{ string }\""
        end

        def val x
          @client.hi x
        end

        def code x
          RegretLib_::CLI_lib[].pen.stylize x, :green
        end

        def par i  # proof of concept - has problems
          par = @client.fetch_parameter i
          stem = RegretLib_::Name_symbol_to_label[ par.local_normal_name ]
          if par.has_arity
            if %i( zero_or_one zero_or_more ).include? par.arity_value
              code "--#{ stem.gsub ' ', '-' }"
            else
              code "<#{ stem.gsub ' ', '-' }>"
            end
          else
            "'#{ RegretLib_::Name_symbol_to_label[ par.local_normal_name ] }'"
          end
        end

        def escape_path pn
          RegretLib_::Pretty_path_proc[][ pn ]
        end

        class Services___
          def initialize x_a
            begin
              send OP_H__.fetch( x_a.shift ), x_a
            end while x_a.length.nonzero? ; nil
          end
          OP_H__ = ::Hash[
            %i( hot_API_action procs ).map { |i| [ i, :"absorb_#{ i }" ] }
          ].freeze

          def absorb_hot_API_action x_a
            _ = x_a.shift ; @hot_API_action_p = -> { _ } ; nil
          end

          def absorb_procs x_a
            cls = self.class  # who needs singleton classes, just bork the class
            a = x_a.shift
            begin
              i, p = a.shift 2
              instance_variable_set (( ivar = :"@#{ i }_p" )), p
              if ! cls.method_defined? i
                cls.send :define_method, i do |*a_, &p_|
                  instance_variable_get( ivar )[ *a_, &p_ ]
                end
              end
            end while a.length.nonzero? ; nil
          end

          def fetch_parameter i, &p
            Fetch_parameter__.new( @hot_API_action_p.call, i, p ).fetch_param
          end

          class Fetch_parameter__
            def initialize bound, i, p
              @bound = bound ; @else_p = p ; @i = i
            end
            def fetch_param
              if @bound.has_field_box
                @box = @bound.field_box
                when_field_box
              else
                raise ::KeyError, "no field box for '#{ @i }'"
              end
            end
          private
            def when_field_box
              @box.fetch @i do
                when_key_not_found
              end
            end
            def when_key_not_found
              if @else_p
                @else_p[ i ]
              else
                do_crazy_lev_thing
              end
            end
            def do_crazy_lev_thing
              raise ::KeyError, say_no_such_param
            end
            def say_no_such_param
              _or = say_lev_or
              "parameter not found: #{ RegretLib_::Ick[ @i ] }. #{
                }did you mean #{ _or }? (#{ @bound.class })"
            end

            def say_lev_or
              TestSupport_::Lib_::Levenshtein[
                :item, @i,
                :closest_N_items, 5,
                :items, @box.get_names,
                :item_proc, -> x { "'#{ x }'" },
                :aggregation_proc, -> a { a * ' or ' } ]
            end
          end
        end

        Services__ = ::Class.new Services___

      end
    end
  end
end
