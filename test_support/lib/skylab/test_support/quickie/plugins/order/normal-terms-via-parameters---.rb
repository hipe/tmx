module Skylab::TestSupport
  module Quickie
    class Plugins::Order

      class NormalTerms_via_Parameters___ < Common_::Dyadic

        def initialize terms, ordered_paths, & listener
          @_listener = listener
          @_ordered_paths = ordered_paths
          @_terms = terms
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
            if :N == x
              a[ d ] = Common_::QualifiedKnownKnown.via_value_and_symbol len, :digit
            end
          end

          first_term = a.fetch 0
          second_term = a[ 1 ]

          ok = true
          val_a = [ [ :first, first_term.value ] ]
          if second_term
            val_a.push [ :second, second_term.value ]
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
          @_listener.call :error, :expression, :primary_parse_error do |y|
            y << "#{ sym } term cannot be #{ d }. must be at least 1."
          end
          UNABLE_
        end

        def __too_high d, len, sym
          @_listener.call :error, :expression, :primary_parse_error do |y|
            y << "#{ sym } term cannot be greater than #{ len }. (had #{ d }.)"
          end
          UNABLE_
        end
      end
    end
  end
end
