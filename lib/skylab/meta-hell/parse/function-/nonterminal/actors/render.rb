module Skylab::MetaHell

  module Parse

    module Function_::Nonterminal

      Actors = ::Module.new

      class Actors::Render

        class << self

          def [] y, x_a, nt
            new( y, x_a, nt ).execute
          end
        end # >>

        def initialize y, x_a, nt
          @nt = nt
          @y = y
          @x_a = x_a
        end

        def execute
          case 1 <=> @x_a.length
          when  1
            @expag = EXPRESSION_AGENT
          when 0
            @expag = @x_a.first
          else
            @expag = EXPRESSION_AGENT.new_via_iambic @x_a
          end
          __via_expag
        end

        class Expag__

          class << self
            def new_with * x_a
              new_via_iambic x_a
            end
          end

          a = [
            :any_first_constituent_string,
            :any_subsequent_constituent_string,
            :constituent_string_via_optional_constituent_badge,
            :render_all_segments_into_under_of_constituent_reflective_function ]

          Callback_::Actor.methodic self, :simple, :properties, :properties, * a

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
          :constituent_string_via_optional_constituent_badge, -> s { "[#{ s }]" },
          :render_all_segments_into_under_of_constituent_reflective_function,
            -> y, expag, f do
              if :field == f.function_supercategory_symbol
                if :keyword == f.function_category_symbol
                  y << f.moniker.as_slug
                else
                  y << f.moniker.as_lowercase_with_underscores_symbol.id2name.upcase
                end
              else
                f.render_all_segments_into_under y, expag
              end
              nil
            end )

        def __via_expag

          st =  @nt.to_reflective_function_stream_

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
          @expag.render_all_segments_into_under_of_constituent_reflective_function[
            y, @expag, f ]

          @expag.constituent_string_via_optional_constituent_badge[ y ]
        end
      end
    end
  end
end
