module Skylab::Brazen

  class CLI::Expression_Frames::Table::Actor

    module Field_Strategies_::Statistics::Models__

      Seer__ = ::Class.new  # part of library impl., re-opens below

      class Taxonomy_Seer__ < Seer__

        def build_new_survey_
          Survey___.new self, Type_taxonomy___[]
        end

        def __appropriate_stringifier

          _bake_stringifier

          method :_stringify
        end

        def _bake_stringifier

          if @_children
            @_children.each_value do | cx |
              cx._bake_stringifier
            end
          end
        end

        def _stringify x

          _sym = classify_ x
          _cx = @_children.h_.fetch _sym
          _cx._stringify x
        end

        IS_TOP_NODE = true  # 1 of 3
      end

      class Survey___

        attr_accessor(
          :numeric_max,
        )

        def initialize seer, type_taxo

          @_top_seer = seer
          @_type_counts = Callback_::Box.new
          @numeric_max = 0
          @_type_taxo = type_taxo
        end

        def _clear
          @_type_counts.algorithms.clear
          @numeric_max = 0
          NIL_
        end

        def seer_class_for sym
          @_type_taxo[ sym ]
        end

        def tick_for sym

          @_type_counts.add_or_replace sym,
            -> do
              0
            end,
            -> d do
              d + 1
            end
          NIL_
        end

        def appropriate_stringifier

          @_top_seer.__appropriate_stringifier
        end
      end

      Type_taxonomy___ = Callback_.memoize do
        Type_Taxonomy___.new self
      end

      class Seer < Taxonomy_Seer__

        def see_cel_argument x

          _see_as classify_( x ), x
        end

        def receive_column_was_re_evaluated

          @_children.algorithms.clear  # just clears the box
          @_survey._clear
          NIL_
        end

        def classify_ x

          if ::Numeric === x
            :numeric
          else
            :non_numeric
          end
        end

        IS_TOP_NODE = true  # 2 of 3
      end

      class Non_Numeric < Taxonomy_Seer__

        def _see x

          _see_as classify_( x ), x
        end

        def classify_ x

          if x
            :trueish_non_numeric
          elsif x.nil?
            :nil
          else
            :false
          end
        end
      end

      class Trueish_Non_Numeric < Non_Numeric

        def _see x
          _see_as_leaf x
        end

        def _bake_stringifier
          NIL_
        end

        def _stringify x
          DEFAULT_STRINGIFIER_[ x ]  # might be TrueClass, string, object, etc
        end
      end

      class Nil < Non_Numeric

        def _see x
          _see_as_leaf x
        end

        def _bake_stringifier
          NIL_
        end

        def _stringify x
          DEFAULT_STRINGIFIER_[ x ]
        end
      end

      class False < Non_Numeric

        def _see x
          _see_as_leaf x
        end

        def _bake_stringifier
          NIL_
        end

        def _stringify fls
          DEFAULT_STRINGIFIER_[ fls ]
        end
      end

      class Numeric < Taxonomy_Seer__

        def _see x

          _see_as classify_( x ), x
        end

        def classify_ x

          if x.respond_to? :finite?
            :float
          else
            :integer
          end
        end

        def _see_as_leaf x

          if @_survey.numeric_max < x
            @_survey.numeric_max = x
          end

          super
        end

        def _bake_stringifier

          if @_children
            h = @_children.h_
            if h[ :float ]
              if h[ :integer ]
                h[ :float ].__marry_data h[ :integer ]
              end
            end
          end

          super
        end
      end

      class Float < Numeric

        def initialize parent

          @_max_big_places = 1  # "123.4" has 3 ("123".length)
          @_max_small_places = 1  # "1.23" has 2 ("12".length)
          @_negative_exists = false

          super
        end

        def _see f

          if f < 0
            @_negative_exists = true
          end

          # because of imperfect precision when doing floating point math,
          # sadly it *seems* we must do string math :( to achieve the desired
          # behavior (try `2.3.divmod 1`, try `2.3 - 2`, try as Rational)

          s = f.to_s
          d = s.index DECIMAL___
          num = s.length - d - 1

          if @_max_big_places < d
            @_max_big_places = d
          end

          if @_max_small_places < num
            @_max_small_places = num
          end

          _see_as_leaf f
        end

        DECIMAL___ = '.'

        def __marry_data guy

          d = guy.max_big_places
          if @_max_big_places < d
            @_max_big_places = d
          else
            guy.__recv_max_big_places @_max_big_places
          end

          if guy.negative_exists
            @_negative_exists = true
          elsif @_negative_exists
            guy.__recv_neg
          end

          NIL_
        end

        def _bake_stringifier

          d = @_max_big_places + 1 + @_max_small_places
          if @_negative_exists  # not sure (but covered in integer counterpart)
            d += 1
          end

          fmt = "%#{ d }.#{ @_max_small_places }f"

          @_p = -> f do

            fmt % f
          end
          NIL_
        end

        def _stringify f
          @_p[ f ]
        end
      end

      class Integer < Numeric

        def negative_exists
          @_negative_exists
        end

        def initialize parent

          @_max_abs_integer = 0
          @_negative_exists = false  # not used currently

          super
        end

        def _see d

          if 0 > d
            abs = -1 * d
            @_negative_exists = true
          else
            abs = d
          end

          if @_max_abs_integer < abs
            @_max_abs_integer = abs
          end

          _see_as_leaf d
        end

        def _bake_stringifier

          num = max_big_places
          if @_negative_exists  # covered!
            num += 1
          end

          fmt = "%#{ num }d"

          @_p = -> d do

            fmt % d
          end
          NIL_
        end

        def max_big_places

          Home_.lib_.basic::Number.of_digits_in_positive_integer(
            @_max_abs_integer )
        end

        def __recv_neg
          @_negative_exists = true
        end

        def __recv_max_big_places d

          @_max_abs_integer = 10 ** d - 1  # HACK
          NIL_
        end

        def _stringify d
          @_p[ d ]
        end
      end

      # ~ impl

      class Seer__  # re-open

        def initialize parent_seer=nil

          @_children = nil

          if parent_seer
            @_survey = parent_seer._survey
          else
            @_survey = build_new_survey_
          end
        end

        def survey
          @_survey
        end

        def _see_as_leaf x

          sv = @_survey

          _sym_a = self.class.all_terminal_name_symbols

          _sym_a.each do | sym |
            sv.tick_for sym
          end

          NIL_
        end

        def _see_as sym, x

          @_children ||= Callback_::Box.new

          _child = @_children.touch sym do
            __build_child_seer sym
          end

          _child._see x
        end

        def __build_child_seer sym

          @_survey.seer_class_for( sym ).new self
        end

        attr_reader :_survey

        class << self

          def all_terminal_name_symbols
            @___did_cache_all_terminal_name_symbols ||= __init_TNS
            @_terminal_name_symbols
          end

          def __init_TNS

            if const_defined? :IS_TOP_NODE, false
              @_terminal_name_symbols = nil
            else

              sym = Callback_::Name.via_module( self ).as_variegated_symbol

              sym_a = superclass.all_terminal_name_symbols
              if sym_a

                sym_a_ = sym_a.dup
                sym_a_.push sym
                @_terminal_name_symbols = sym_a_
              else
                @_terminal_name_symbols = [ sym ].freeze
              end
            end
            ACHIEVED_
          end
        end  # >>

        IS_TOP_NODE = true  # 3 of 3
      end

      class Type_Taxonomy___

        def initialize mod
          @_mod = mod
          @_name_cache = {}
        end

        def [] sym
          @_name_cache.fetch sym do
            _const = Callback_::Name.via_variegated_symbol( sym ).as_const
            @_name_cache[ sym ] = @_mod.const_get _const, false
          end
        end
      end

      # (the below moved here with the file but have become detached frm tests)

    # it is a pesudo-proc ..
    #
    #     Table = Face_::CLI::Table
    #
    #
    # call it with nothing and it renders nothing:
    #
    #     Table[]  # => nil
    #
    #
    # call it with one thing, must respond to each (in two dimensions)
    #
    #     Table[ :a ]  # => NoMethodError: "private method .."
    #
    #
    # that is, an array of atoms won't fly either
    #
    #     Table[ [ :a, :b ] ]  # => NoMethodError: undefined method `each_wi..
    #
    #
    # here is the smallest table you can render, which is boring
    #
    #     Table[ [] ]  # => ''
    #
    #
    # default styling ("| ", " |") is evident in this minimal non-empty table:
    #
    #     Table[ [ [ 'a' ] ] ]   # => "| a |\n"
    #
    #
    # the default styling also includes " | " as the middle separator
    # and text cels aligned left with this
    # minimal normative example:
    #
    #     act = Table[ [ [ 'Food', 'Drink' ], [ 'donuts', 'coffee' ] ] ]
    #     exp = <<-HERE.gsub %r<^ +>, ''
    #       | Food   | Drink  |
    #       | donuts | coffee |
    #     HERE
    #     act  # => exp

    # specify custom headers, separators, and output functions:
    #
    #     a = []
    #     x = Face_::CLI::Table[ :field, 'Food', :field, 'Drink',
    #       :left, '(', :sep, ',', :right, ')',
    #       :read_rows_from, [[ 'nut', 'pomegranate' ]],
    #       :write_lines_to, a ]
    #
    #     x  # => nil
    #     ( a * 'X' )  # => "(Food,Drink      )X(nut ,pomegranate)"

    # add field modifiers between the `field` keyword and its label (left/right):
    #
    #     str = Face_::CLI::Table[
    #       :field, :right, :label, "Subproduct",
    #       :field, :left, :label, "num test files",
    #       :read_rows_from, [ [ 'face', 100 ], [ 'headless', 99 ] ] ]
    #
    #     exp = <<-HERE.unindent
    #       | Subproduct | num test files |
    #       |       face | 100            |
    #       |   headless | 99             |
    #     HERE
    #     str # => exp

    # but the real fun begins with currying
    # you can curry properties and behavior for table in one place ..
    #
    #     P = Face_::CLI::Table.curry :left, '<', :sep, ',', :right, ">\n"
    #
    #
    # and then use it in another place:
    #
    #     P[ [ %w(a b), %w(c d) ] ]  # => "<a,b>\n<c,d>\n"
    #
    #
    # you can optionally modify the properties for your call:
    #
    #     P[ :sep, ';', :read_rows_from, [%w(a b), %w(c d)] ]  # => "<a;b>\n<c;d>\n"
    #
    #
    #
    # you can even curry the curried "function", curry the data, and so on -
    #
    #     q = P.curry( :read_rows_from, [ %w( a b ) ], :sep, 'X' )
    #     q[ :sep, '_' ]  # => "<a_b>\n"
    #     q[]  # => "<aXb>\n"

    end
  end
end
