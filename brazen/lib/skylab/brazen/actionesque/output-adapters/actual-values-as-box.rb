module Skylab::Brazen
  # -> 2
      class Actionesque::Output_Adapters::Actual_Values_as_Box

        def initialize argument_box, formals
          @argument_box = argument_box
          @fo = formals
          @h = {}
        end

        def members ; [ :fo, :argument_box ] end

        attr_reader :fo, :argument_box

        def any_trueish k
          x = @argument_box[ k ]
          x and begin
            Common_::Qualified_Knownness.via_value_and_association x, @fo.fetch( k )
          end
        end

        def [] k
          fetch k do end
        end

        def fetch k, & p

          @h.fetch k do

            had_x = true
            x = @argument_box.fetch k do
              had_x = false
              nil
            end

            had_f = true
            f = @fo.fetch k do
              had_f = false
              nil
            end

            if had_f || had_x
              Common_::Qualified_Knownness.via_value_and_had_and_association x, had_x, f
            elsif p
              p[]
            else
              raise ::KeyError, "no formal or actual argument '#{ k }'"
            end
          end
        end

        def to_value_stream

          a = @argument_box.a_
          fo = @fo
          h = @argument_box.h_

          Common_::Stream.via_times a.length do | d |

            k = a.fetch d
            Common_::Qualified_Knownness.via_value_and_association(
              h.fetch( k ), fo.fetch( k ) )
          end
        end
      end
      # <- 2
end
