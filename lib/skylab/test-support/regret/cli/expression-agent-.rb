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

        Headless::SubClient::EN_FUN[ self, :private, [ :and_, :or_, :s ] ]

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
          Headless::CLI::Pen::FUN::Stylize[ [ :green ], x ]
        end

        def par i  # proof of concept - has problems
          par = @client.fetch_parameter i
          stem = Headless::Name::Labelize[ par.local_normal_name ].downcase
          if par.has_arity
            if %i( zero_or_one zero_or_more ).include? par.arity_value
              code "--#{ stem.gsub ' ', '-' }"
            else
              code "<#{ stem.gsub ' ', '-' }>"
            end
          else
            "'#{ Headless::Name::Labelize[ par.local_normal_name ].downcase }'"
          end
        end

        def escape_path pn
          Headless::CLI::PathTools::FUN.pretty_path[ pn ]
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
            hot = @hot_API_action_p.call
            if hot.has_field_box
              hot.field_box.fetch i, &p
            elsif p then p else raise ::KeyError, "no field box for '#{ i }'" end
          end
        end

        Services__ = ::Class.new Services___

      end
    end
  end
end
