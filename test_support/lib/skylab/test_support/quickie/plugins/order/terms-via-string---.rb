module Skylab::TestSupport
  module Quickie
    class Plugins::Order

      class Terms_via_String___ < Common_::Monadic

        def initialize s, & p
          @__listener = p
          @_s = s
        end

        def execute

          dash = /-/
          dash_s = '-'

          n = /n/i
          n_s = "N"

          digit = /[0-9]+/

          scn = Home_::Library_::StringScanner.new @_s
          @_strscan = scn

          parse_end = -> do
            if scn.eos?
              _flush
            else
              _expecting
            end
          end

          after_digit_and_dash = -> do

            if scn.eos?
              _expecting n_s

            elsif scn.skip n
              _accept :N
              parse_end[]

            else
              s = scn.scan digit
              if s
                _accept :digit, s.to_i
                parse_end[]
              else
                _expecting :digit, n_s
              end
            end
          end

          after_N_and_dash = -> do

            if scn.eos?
              _expecting :digit

            else
              s = scn.scan digit
              if s
                _accept :digit, s.to_i
                parse_end[]
              else
                _expecting :digit
              end
            end
          end

          parse_nothing_or_dash_then = -> p do
            if scn.eos?
              _flush
            elsif scn.skip dash
              p[]
            else
              _expecting dash_s
            end
          end

          @_terms = []

          s = scn.scan digit
          if s
            _accept :digit, s.to_i
            parse_nothing_or_dash_then[ after_digit_and_dash ]

          elsif scn.skip n

            _accept :N
            parse_nothing_or_dash_then[ after_N_and_dash ]

          else
            _expecting :digit, n_s
          end
        end

        def _accept sym, * rest
          a = @_terms
          if rest.length.zero?
            a.push sym
          else
            a.push Common_::Pair.via_value_and_name( * rest, sym )
          end
          NIL_
        end

        def _expecting * x_a

          _exp_s = if x_a.length.zero?
            'nothing'
          else
            _s_a = x_a.map do | x |
              if x.respond_to? :id2name
                "<#{ x }>"
              else
                x.inspect
              end
            end
            Common_::Oxford_or[ _s_a ]
          end

          scn = @_strscan

          _prep = if scn.eos?
            "at end of input"
          else
            "for #{ scn.rest.inspect }"
          end

          @__listener.call :error, :expression, :primary_parse_error do |y|
            y << "expecting #{ _exp_s } #{ _prep }"
          end
          UNABLE_
        end

        def _flush
          @_terms
        end
      end
    end
  end
end
