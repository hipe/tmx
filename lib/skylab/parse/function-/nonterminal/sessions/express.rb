module Skylab::MetaHell

  module Parse

    module Function_::Nonterminal

      Sessions = ::Module.new

      class Sessions::Express

        class << self

          def session
            o = new
            yield o
            o.__execute
          end
        end  # >>

        def initialize
          @cdpsbs = true
          @x_h = {}
        end

        def accept_iambic x_a
          process_iambic_stream_fully iambic_stream_via_iambic_array x_a
          nil
        end

        Callback_::Actor.methodic self

      private

        def any_first_constituent_string=
          @expag = nil
          @x_h[ :any_first_constituent_string ] = iambic_property
          KEEP_PARSING_
        end

        def any_subsequent_constituent_string=
          @expag = nil
          @x_h[ :any_subsequent_constituent_string ] = iambic_property
          KEEP_PARSING_
        end

        def constituent_string_via_constituent_badge=
          @cdpsbs = false
          @expag = nil
          @x_h[ :constituent_string_via_constituent_badge ] = iambic_property
          KEEP_PARSING_
        end

        def express_all_segments_into_under_of_constituent_reflective_function=
          @expag = nil
          @x_h[ :express_all_segments_into_under_of_constituent_reflective_function ] = iambic_property
          KEEP_PARSING_
        end

      public

        # ~ readers for use in session

        def constituent_delimiter_pair_should_be_specified
          @cdpsbs
        end

        def expression_agent
          @expag ||= __build_expression_agent
        end

        def __build_expression_agent
          if @x_h.length.zero?
            EXPRESSION_AGENT
          else
            x_a = []
            @x_h.each_pair do | sym, x |
              x_a.push sym, x
            end
            EXPRESSION_AGENT.new_via_iambic x_a
          end
        end

        # ~ setters for use in session

        def set_constituent_delimiter_pair _OPEN_DELIMITER=nil, _CLOSE_DELIMITER=nil
          @expag = nil
          @cdpsbs = false
          @x_h[ :constituent_string_via_constituent_badge ] = -> s do
            "#{ _OPEN_DELIMITER }#{ s }#{ _CLOSE_DELIMITER }"
          end
          nil
        end

        def set_downstream x
          @y = x
          nil
        end

        def set_expression_agent x
          if x
            @cdpsbs = false
          end
          @expag = x
          nil
        end

        def set_reflective_function_stream x
          @reflective_function_stream = x
          nil
        end

        # ~ implementation

        def __execute
          expression_agent
          __via_expag
        end

        class Expag__

          a = [
            :any_first_constituent_string,
            :any_subsequent_constituent_string,
            :constituent_string_via_constituent_badge,
            :express_all_segments_into_under_of_constituent_reflective_function ]

          Callback_::Actor.methodic self, :property_list, a

          attr_reader( * a )

          def initialize & edit_p
            instance_exec( & edit_p )
            freeze
          end

          def new_via_iambic x_a
            ok = nil
            x = dup.instance_exec do
              ok = process_iambic_stream_fully iambic_stream_via_iambic_array x_a
              self
            end
            ok && x.freeze
          end
        end

        EXPRESSION_AGENT = Expag__.new_with(
          :any_first_constituent_string, MetaHell_::IDENTITY_,
          :any_subsequent_constituent_string, -> s { " #{ s }" },
          :express_all_segments_into_under_of_constituent_reflective_function,
            -> y, expag, f do
              f.express_all_segments_into_under y, expag
              nil
            end )

        def __via_expag

          st =  @reflective_function_stream

          f = st.gets
          f and __when_at_least_one_item f, st

          @y
        end

        def __when_at_least_one_item f, st

          s = @expag.any_first_constituent_string[ render_child f ]
          s and @y << s

          f = st.gets
          while f

            s = @expag.any_subsequent_constituent_string[ render_child f ]
            s and @y << s

            f = st.gets
          end
          nil
        end

        def render_child f
          y = ""
          @expag.express_all_segments_into_under_of_constituent_reflective_function[
            y, @expag, f ]

          @expag.constituent_string_via_constituent_badge[ y ]
        end
      end
    end
  end
end
