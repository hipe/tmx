module Skylab::Snag

  class Models_::Node_Identifier

    Models_ = ::Module.new

    class Models_::Suffix  # described in the node identifier spec

      class << self

        def parse s
          Parse___[ s ]
        end
      end # >>

      def initialize a
        @to_a = a
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

      Parse___ = -> do

        separator = /[-.\/]/

        string_value  = / [^-.\/0-9]  [^-.\/]*  /x

          # one not separator or digit character followed by
          # zero or more not separator characters

        integer_value = / -? \d+ /x


        -> s do

          a = []
          scn = Snag_::Library_::StringScanner.new s
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
                value_category_symbol = :string
                value_x = scn.rest
                scn.pos = scn.string.length
              end
            end

            a.push Component___.new(
              separator_string,
              value_category_symbol,
              value_x ).freeze

            scn.eos? and break
            redo
          end while nil

          Suffix_.new a.freeze
        end
      end.call

      class Component___

        def initialize *a
          @separator_string, @value_category_symbol, @value = a
          freeze
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

      Suffix_ = self
    end
  end
end
