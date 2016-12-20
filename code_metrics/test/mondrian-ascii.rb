module Skylab::CodeMetrics::TestSupport

  module Mondrian_ASCII

    def self.[] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end

    module ModuleMethods___

      def given_mondrian_tree & p  # assumes [#016] that you are `use`ing something else
        yes = true ; sl = nil
        once = -> tc do
          yes = false ; once = nil
          _mt = tc.instance_exec( & p )
          sl = Home_::Magnetics::ShapesLayers_via_MondrianTree[ _mt ]
          NIL
        end
        define_method :_mondrian_ASCII_shapes_layers do
          yes && once[ self ]
          sl
        end
      end

      def given_choices & p
        yes = true ; cx = nil
        once = -> do
          yes = false ; once = nil
          cx = if p.arity.zero?
            p[]
          else
            Home_::Models::MondrianAsciiChoices.define do |o|
              p[ o ]
            end
          end
          NIL
        end
        define_method :_mondrian_ASCII_choices do
          yes && once[]
          cx
        end
      end

      def given_shapes_layers & p
        yes = true ; sl = nil
        once = -> do
          yes = false ; once = nil
          sl = if p.arity.zero?
            p[]
          else
            Home_::Models::ShapesLayers.define do |o|
              p[ o ]
            end
          end
          NIL
        end
        define_method :_mondrian_ASCII_shapes_layers do
          yes && once[]
          sl
        end
      end

      def will_expect_big_string & p
        _p_ = method_definition_for_big_stringer_for( & p )
        define_method :big_stringer, _p_
      end

      def method_definition_for_big_stringer_for & p
        yes = true ; proto = nil
        once = -> do
          yes = false ; once = nil
          proto = Big_stringer_prototype___[].new p[]
          NIL
        end
        -> do
          yes && once[]
          proto
        end
      end
    end

    Big_stringer_prototype___ = Lazy_.call do

      TestSupport_::Expect_Line::DemarcatedBigString.define do |o|
        o.demarcator_string = "¦"
        o.have_the_effect_of_chomping_lines = true
      end
    end

    module InstanceMethods___

      def _DEBUG_BY_FLUSH_AND_EXIT

        act_st = _mondrian_ASCII_build_line_stream

        io = debug_IO
        io.puts "_____"
        while line = act_st.gets
          io.puts line
        end
        io.puts "---- (EXIT by [cm]!)"
        exit 0
      end

      def expect_every_byte_is_correct_

        _act_st = _mondrian_ASCII_build_line_stream

        _exp = big_stringer

        _exp.expect_against_line_stream_under _act_st, self
      end

      def _mondrian_ASCII_build_line_stream

        _sl = _mondrian_ASCII_shapes_layers
        _cx = _mondrian_ASCII_choices

        mondrian_ASCII_subject_module_[ _sl, _cx ]
      end

      def squareish_in_ASCII_
        Rational( 6 ) / Rational( 11 )
      end

      def mondrian_ASCII_subject_module_
        Home_::Magnetics::AsciiMatrix_via_ShapesLayers
      end
    end
  end
end
