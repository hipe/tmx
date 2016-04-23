module Skylab::Zerk

  class InteractiveCLI

  class Frame_ViewController___

    # the top view controller. assembles and expresses the whole "screen"
    # as well as providing parameters to component view controllers.

    def initialize stack, resources, comp_kn, loc_kn, prim_kn

      b9r = resources.boundarizer
      @_boundarizer = b9r
      @line_yielder = b9r.line_yielder
      @expression_agent = EXPAG___  # etc
      @serr = resources.serr
      @stack = stack

      h = {}
      h[ :branchesque ] = -> do
        @compound_frame.call @line_yielder  # imagine `express_compound_frame_into__`
        NIL_
      end
      h[ :entitesque ] = -> do
        stack.last.express_entitesque_frame__  # has self as member
        NIL_
      end
      h[ :primitivesque ] = -> do
        @primitive_frame.call @line_yielder  # imagine `express_primitive_frame_into_`
        NIL_
      end
      @_op_h = h

      _init comp_kn, :@compound_frame, :Compound_Frame_ViewController___

      _init loc_kn, :@location, :Location_ViewController___

      _init prim_kn, :@primitive_frame, :Atomesque_Frame_ViewController_
    end

    def _init kn, ivar, const

      # per #thread-three, we can distinguish here if the user set the
      # value to false-ish versus the user having not set the value
      # (if we allowed for this, which we don't now. but we could.

      proto = if kn
        kn.value_x
      else
        Here_.const_get( const, false ).default_instance
      end

      _x = if proto
        proto[ self ]
      end

      instance_variable_set ivar, _x
      NIL_
    end

    def express

      ada = @stack.last
      ada.begin_UI_frame
      @_op_h.fetch( ada.shape_symbol ).call
      ada.end_UI_frame
      NIL_
    end

    # -- for lower-level modules

    def express_buttonesques buttons

      _st = Callback_::Stream.via_nonsparse_array buttons  # while it works

      _buff = _st.join_into_with_using_by "", SPACE_, :<< do |btn|
        "#{ btn.head }[#{ btn.hotstring_for_expression }]#{ btn.tail }"
      end

      @line_yielder << _buff
      NIL_
    end

    def express_location_area

      @location.call @line_yielder
      NIL_
    end

    def touch_boundary
      @_boundarizer.touch_boundary
      NIL_
    end

    def main_view_controller
      self
    end

    attr_reader(
      :expression_agent,
      :line_yielder,  # [sa]
      :primitive_frame,
      :serr,
      :stack,
    )

    class Expag___  # < ::BasicObject

      alias_method :calculate, :instance_exec

      rx = nil
      define_method :singularize do | s |  # #open [#hu-045]
        rx ||= /\A.+(?=s\z)/
        rx.match( s )[ 0 ]
      end

      def plural_noun count_d=nil, s
        Home_.lib_.human::NLP::EN::POS.plural_noun count_d, s
      end

      def s d
        if 1 != d
          S___
        end
      end
      S___ = 's'
    end

    EXPAG___ = Expag___.new
  end

  end
end
