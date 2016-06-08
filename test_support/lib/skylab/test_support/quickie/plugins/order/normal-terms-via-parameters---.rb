module Skylab::TestSupport
  module Quickie
    class Plugins::Order

      class Normal_terms_via_parameters___

        class << self
          def [] a, b, c
            new( a, b, c ).execute
          end
          private :new
        end  # >>

        def initialize terms, ordered_paths, y
          @_terms = terms
          @_ordered_paths = ordered_paths
          @_y = y
        end

        def execute

          a = []
          p = -> t { a.push t }
          h = [ p, p ]

          @_terms.each_with_index do | t, d |
            h.fetch( d )[ t ]
          end

          len = @_ordered_paths.length

          a.each_with_index do | x, d |
            if :N == x.to_sym
              a[ d ] = Common_::Pair.via_value_and_name( len, :digit )
            end
          end

          first_term = a.fetch 0
          second_term = a[ 1 ]

          ok = true
          val_a = [ [ :first, first_term.value_x ] ]
          if second_term
            val_a.push [ :second, second_term.value_x ]
          end

          val_a.each do |sym, d|
            if 1 > d
              ok = ___too_low d, sym
              break
            end
            if len < d
              ok = __too_high d, len, sym
              break
            end
          end
          if ok
            a
          else
            ok
          end
        end

        def ___too_low d, sym
          @_y << "#{ sym } term cannot be #{ d }. must be at least 1."
          UNABLE_
        end

        def __too_high d, len, sym
          @_y << "#{ sym } term cannot be greater than #{ len }. (had #{ d }.)"
          UNABLE_
        end
      end
    end
  end
end
