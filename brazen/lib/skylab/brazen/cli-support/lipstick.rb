module Skylab::Brazen

  module CLI_Support::Lipstick  # see [#073]

    # ~ phase 1: "static" definition

    class << self

      def build_with * x_a
        o = Build_class___.new
        o.x_a = x_a
        o.execute
      end
    end  # >>

    class Build_class___

      attr_writer :x_a

      def execute

        @_cls = ::Class.new Expressor___
        @_seg_a = nil
        @_ewp = nil

        process_iambic_fully remove_instance_variable :@x_a

        cls = remove_instance_variable :@_cls
        cls.const_set :EXPRESSION_WIDTH_PROC, @_ewp  # migth be nil
        cls.const_set :SEGMENTS, @_seg_a  # might be nil
        cls
      end

      Attributes_actor_[ self ]

    private

      def expression_width_proc=
        @_ewp = gets_one_polymorphic_value
        KEEP_PARSING_
      end

      def segment=

        seg = Formal_Segment___.new_via_polymorphic_stream_passively(
          @_polymorphic_upstream_ )

        ( @_seg_a ||= [] ).push seg

        KEEP_PARSING_
      end
    end

    class Formal_Segment___

      Attributes_actor_.call( self,
        :color,
        :glyph,
      )

      def process_polymorphic_stream_passively st  # #[#fi-022]
        _k = super
        _k && normalize
      end

      def normalize
        @glyph ||= GLYPH___

        if 1 == @glyph.length
          KEEP_PARSING_
        else
          raise ::ArgumentError, __say_glyph_width
        end
      end

      def __say_glyph_width
        "glyph must be of width 1: #{ @glyph.inspect }"
      end

      def __build_style_proc
        if @color
          Home_::CLI_Support::Styling::Stylify.curry[ [ @color ] ]
        else
          IDENTITY_
        end
      end

      attr_reader(
        :color,
        :glyph,
      )
    end

    # ~ phase 2: building the proc

    class Expressor___

      # assume these consts: `EXPRESSION_WIDTH_PROC`, `SEGMENTS`

      Attributes_actor_.call( self,
        :expression_width,
      )

      class << self

        def new_expressor
          sess = new
          sess.normalize && sess._to_proc
        end

        def new_expressor_with * x_a
          sess = new
          _k = sess.send :process_iambic_fully, x_a
          _k && sess._to_proc
        end

        private :new
      end  # >>

      def initialize
        @expression_width = nil
      end

      def process_polymorphic_stream_passively st  # #[#fi-022]
        super && normalize
      end

      def normalize

        cls = self.class

        @expression_width_proc ||= cls::EXPRESSION_WIDTH_PROC

        @segments ||= cls::SEGMENTS

        @_number_of_segments = @segments.length

        KEEP_PARSING_
      end

      def _to_proc

        # this produces a proc that anticipates being called for perhaps
        # *many* records, so every calculation that can be done early is.

        # however, it also anticipates getting strange data thrown at it,
        # so every single "record"'s worth of floats is validated.

        express_via_normal_floats = __build_express_via_normal_floats_proc

        -> * f_a do

          if @_number_of_segments == f_a.length

            sum = 0.0
            f_a.each_with_index do | f, d |
              if ! f
                f = 0.0
                f_a[ d ] = f
              end
              if NORMAL_FLOAT_RANGE__.include? f
                sum += f
              else
                raise ::ArgumentError, __say_abnormal_float( f )
              end
            end

            if NORMAL_FLOAT_RANGE__.include? sum
              express_via_normal_floats[ f_a ]
            else
              raise ::ArgumentError, __say_abnormal_sum( sum, f_a )
            end
          else
            raise ::ArgumentError, __say_arglength( f_a.length )
          end
        end
      end

      def __say_abnormal_float f
        "must be #{ NORMAL_FLOAT_RANGE__ }: #{ f }"
      end

      def __say_abnormal_sum sum, f_a
        "sum must be #{ NORMAL_FLOAT_RANGE__ } (had #{ sum }) of #{
          }(#{ f_a * ', ' })"
      end

      def __say_arglength d
        "wrong number of arguments (#{ d } for #{ @segments.length })"
      end

      def __build_express_via_normal_floats_proc

        segment_expressors = __build_segment_expressors

        -> f_a do  # assume each component is normal and sum is normal

          s_a = []
          tot = 0.0

          @_number_of_segments.times do | d |

            _express_segment = segment_expressors.fetch d

            float = f_a.fetch d

            tot += float

            styled_string = _express_segment[ float ]

            if styled_string

              s_a.push styled_string
            end
          end

          s_a * EMPTY_S_
        end
      end

      def __build_segment_expressors

        w = __produce_some_width
        w_f = w.to_f

        surplus_f = 0.0  # this is sketchy just floating here, but it will
          # work as long as our rendering logic doesn't change. see below

        eek = 1 == @segments.length

        @segments.map do | seg |

          glyph_s = seg.glyph

          style_p = seg.__build_style_proc

          -> normal_f do

            glyph_f = w_f * normal_f

            glyph_d, extra_f = glyph_f.divmod 1.0

            surplus_f += extra_f  # #.B
            if 1.0 <= surplus_f
              glyph_d += 1
              surplus_f -= 1.0
            end

            unstyled_string = glyph_s * glyph_d

            styled_string = style_p[ unstyled_string ]

            if eek

              _number_of_empty_cels = w - glyph_d

              _empty_spacer_string = SPACE_ * _number_of_empty_cels  # etc

              "#{ styled_string }#{ _empty_spacer_string }"
            else
              styled_string
            end
          end
        end
      end

      def __produce_some_width

        w = @expression_width

        if ! w

          p = @expression_width_proc

          if p
            w = p[]
          end

          w ||= WIDTH___
        end
        w
      end
    end

    GLYPH___ = '.'
    NORMAL_FLOAT_RANGE__ = 0.0 .. 1.0
    WIDTH___ = 72
  end
end
