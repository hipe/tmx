module Skylab::SearchAndReplace

    class Magnetics_::Replace_Function_via_String_and_Functions_Dir

      Parse_error__ = Callback_::Event.prototype_with(

        :replace_function_parse_error,
        :expecting, nil,
        :near_excerpt, nil,
        :ok, false,
      ) do | y, o |

        _s_a = o.expecting.map do | o_ |
          o_.description_under self
        end

        y << "expecting #{ _s_a * ' or ' }:"
        y << o.near_excerpt
        y << "#{ '-' * o.near_excerpt.length }^"
      end

      class Parse_error__

        class << self

          def [] * shorthand_things, scn

            pos = scn.pos  # we use `pos` and not `charpos` here only
              # because string scanners allow you to assign the former
              # but not the latter.

            str = scn.scan %r([^\n]*)
            scn.pos = pos  # eek
            _x_a = shorthand_things.map do |x|
              if x.respond_to? :id2name
                Symbol__.new x
              else
                Literal__.new x
              end
            end

            super _x_a, str  # eek
          end
        end  # >>

        class Symbol__

          def initialize x
            @name = Callback_::Name.via_variegated_symbol x
          end

          def category
            :symbol
          end

          attr_reader :name

          def description_under _expag
            "<#{ @name.as_human }>"
          end
        end

        class Literal__

          def initialize x
            @x = x
          end

          def category
            :literal
          end

          attr_reader :x

          def description_under _expag
            @x.inspect
          end
        end
      end
    end
  # -
end
