module Skylab::Human

  class NLP::EN::Contextualization

    class Magnetics_::Expression_via_Emission

      # (mostly to help migrate to here whatever [br] used to do)

      class << self
        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize
        @etc1 = nil
        @etc2 = nil
      end

      # -- the argument parameters:

      attr_writer(
        :collection,
        :line_yielder,
      )

      attr_accessor(  # (as above but also read by sub-clients)
        :channel,
        :emission_proc,
        :expression_agent,
      )

      def execute

        path = []
        path.push __etc1
        path.push __etc2

        o = Magnetics_::Solution_via_Parameters_and_Function_Path_and_Collection.begin
        o.function_symbol_path = path
        o.collection = @collection
        o.parameters = self  # so we don't pollute the top parameter namespace
        st = o.execute

        y = @line_yielder
        begin
          s = st.gets
          s || break
          y << s
          redo
        end while nil
        y
      end

      def __etc1
        _x = @etc1
        if _x
          Home_._COVER_ME
        else
          :Line_Stream_via_Expression_Proc_and_Channel
        end
      end

      def __etc2
        _x = @etc2
        if _x
          Home_._COVER_ME
        else
          :Contextualized_Line_Stream_via_Line_Stream_and_Emission
        end
      end

      # -- ours only (still for clients) (the bulk of this would move)

      Magnetic_required_attr_accessor_ = -> cls, * sym_a do

        cls.class_exec do

          sym_a.each do |sym|

            define_method "#{ sym }=" do |x|
              write_magnetic_value x, sym
            end

            define_method sym do
              read_magnetic_value sym
            end

            param=nil

            define_method :"__#{ sym }__mag_param" do
              param ||= Magnetic_Parameter_.new( sym, true )
            end
          end
          NIL_
        end
      end

      Magnetic_required_attr_accessor_.call( self,
        :event,
        :line_stream,
        :trilean,
      )

      def magnetic_value_is_known sym
        instance_variable_defined? send( :"__#{ sym }__mag_param" ).ivar
      end

      def write_magnetic_value x, sym
        instance_variable_set send( :"__#{ sym }__mag_param" ).ivar, Common_::Known_Known[ x ]
      end

      def read_magnetic_value sym
        instance_variable_get( send( :"__#{ sym }__mag_param" ).ivar ).value_x
      end
    end
  end
end
