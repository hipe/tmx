module Skylab::Snag

  class Models_::Node_Identifier

    Models_ = ::Module.new

    class Models_::Suffix  # described in the node identifier spec

      Interpret = -> scn, _, & x_p do

        a = Interpret_out_of_string_scanner__[ scn, & x_p ]
        a and new a
      end

      class << self

        def new_via__string__ s, & x_p

          _scn = Home_::Library_::StringScanner.new s
          a = Interpret_out_of_string_scanner__[ _scn, & x_p ]
          a and new a
        end

        private :new
      end  # >>

      def initialize a
        @to_a = a
      end

      def express_into_under y, expag

        @to_a.each do | x |
          x.express_into_under y, expag
        end
        y
      end

      def express_into_ y

        @to_a.each do | x |
          x.express_into_ y
        end
        y
      end

      attr_reader :to_a

      include ::Comparable

      def <=> otr
        if otr.kind_of? Suffix_

          a = @to_a
          a_ = otr.to_a

          d = -1
          last = [ a.length, a_.length ].min - 1

          made_it_to_the_end = true
          while d < last
            d += 1
            o = a.fetch d
            o_ = a_.fetch d

            cmp_d = o <=> o_
            if cmp_d.nonzero?
              made_it_to_the_end = false
              x = cmp_d
              break
            end
          end

          if made_it_to_the_end
            0
          else
            x
          end
        end
      end

      def separator_at_index d

        component = @to_a[ d ]
        if component
          component.separator_string
        end
      end

      def value_at_index d

        component = @to_a[ d ]
        if component
          component.value
        end
      end

      Interpret_out_of_string_scanner__ = -> do

        integer_value = / -? \d+ /x

        multi_suffix_as_string = / -{2,} | \.{2,} | \/{2,} /x

        separator = /[-.\/]/

        string_value  = /[a-zA-Z_] [a-zA-Z0-9_']* /x  # Bill's_Barbecue_2015 or whatever meh

        -> scn, & oes_p_p do

          a = nil

          begin
            separator_string = scn.scan separator
            string = scn.scan string_value

            if string
              value_category_symbol = :string
              value_x = string

            else
              integer_s = scn.scan integer_value

              if integer_s
                value_category_symbol = :integer
                value_x = integer_s.to_i

              else
                string = scn.scan multi_suffix_as_string
                if string
                  value_category_symbol = :string
                  value_x = string
                else

                  break
                end
              end
            end

            a ||= []

            a.push Component___.new(
              separator_string,
              value_category_symbol,
              value_x ).freeze

            scn.eos? and break
            redo
          end while nil

          if a
            a.freeze
          elsif oes_p_p
            _oes_p = oes_p_p[ nil ]
            _oes_p.call :error, :parse_error, :suffix_expected do
              Expecting___[ scn, :suffix ]
            end
          end
        end
      end.call

      class Component___

        def initialize *a
          @separator_string, @value_category_symbol, @value = a
          freeze
        end

        def express_into_under y, expag

          :Event == expag.intern or self._DO_ME
          express_into_ y
          y
        end

        def express_into_ y
          y << @separator_string
          y << @value.to_s
          ACHIEVED_
        end

        attr_reader :separator_string, :value_category_symbol, :value

        include ::Comparable

        def <=> otr
          if otr.kind_of? Component___

            ss = @separator_string
            ss_ = otr.separator_string
            if ss
              if ss_
                d = ss <=> ss_
                if d.zero?
                  _compare_by_value otr
                else
                  d
                end
              else
                # i have a sep string but the other does not. i come after
                1
              end
            elsif ss_
              # i have no sep string but the other does. i come before
              -1
            else
              _compare_by_value otr
            end
          end
        end

        def _compare_by_value otr

          d = SHAPE_RANK___.fetch( @value_category_symbol ) <=>
            SHAPE_RANK___.fetch( otr.value_category_symbol )

          if d.zero?
            @value <=> otr.value
          else
            d
          end
        end
        SHAPE_RANK___ = { integer: 0, string: 1 }
      end

      Expecting___ = -> scn, sym do

        Common_::Event.inline_not_OK_with(
            :suffix_parse_error,
            :x, scn.rest,
            :expecting_symbol, sym,
            :error_category, :argument_error ) do | y, o |

          y << "invalid #{ o.expecting_symbol }: #{ ick o.x }"
        end
      end

      Suffix_ = self
    end
  end
end
