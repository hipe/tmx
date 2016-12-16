module Skylab::CodeMetrics::TestSupport

  module Mondrian_ASCII

    def self.[] tcc
      tcc.extend ModuleMethods___
      tcc.include InstanceMethods___
    end

    module ModuleMethods___

      def given_choices & p
        yes = true ; x = nil
        define_method :__mondrian_ASCII_choices do
          if yes
            yes = false
            x = if p.arity.zero?
              p[]
            else
              Home_::Models::MondrianAsciiChoices.define do |o|
                p[ o ]
              end
            end
          end
          x
        end
      end

      def given_shapes_layers & p
        yes = true ; x = nil
        define_method :__mondrian_ASCII_shapes_layers do
          if yes
            yes = false
            x = if p.arity.zero?
              p[]
            else
              Home_::Models::ShapesLayers.define do |o|
                p[ o ]
              end
            end
          end
          x
        end
      end

      def will_expect_big_string & p
        _p_ = method_definition_for_big_stringer_for( & p )
        define_method :big_stringer, _p_
      end

      def method_definition_for_big_stringer_for & p
        yes = true ; x = nil
        -> do
          if yes
            yes = false
            x = Big_stringer_prototype___[].new p[]
          end
          x
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

      def _DEBUG_BY_FLUSHING
        @__DO_DEBUG_BY_FLUSHING = true
      end

      attr_reader( :__DO_DEBUG_BY_FLUSHING )

      def expect_every_byte_is_correct_

        _act_st = __mondrian_ASCII_build_line_stream

        if __DO_DEBUG_BY_FLUSHING
          io = debug_IO
          io.puts "_____"
          while line = _act_st.gets
            io.puts line
          end
          io.puts "----"
          exit 0
        end

        _exp = big_stringer

        _exp.expect_against_line_stream_under _act_st, self
      end

      def __mondrian_ASCII_build_line_stream

        _sl = __mondrian_ASCII_shapes_layers
        _cx = __mondrian_ASCII_choices

        mondrian_ASCII_subject_module_[ _sl, _cx ]
      end

      def mondrian_ASCII_subject_module_
        Home_::Magnetics::AsciiMatrix_via_ShapesLayers
      end
    end
  end
end
