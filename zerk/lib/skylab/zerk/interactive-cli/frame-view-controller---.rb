module Skylab::Zerk

  class InteractiveCLI

  class Frame_ViewController___

    # (built only by view maker maker. lives only in top client.)

    # the top view controller. assembles and expresses the whole "screen"
    # as well as providing parameters to component view controllers.

    def initialize top_frame_p, resources, comp_kn, loc_kn, prim_kn

      b9r = resources.boundarizer
      @_boundarizer = b9r
      @line_yielder = b9r.line_yielder
      @expression_agent = EXPAG___  # etc
      @produce_top_frame = top_frame_p
      @serr = resources.serr

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

      ada = @produce_top_frame.call
      @_top_frame = ada
      ada.begin_UI_frame
      send EXPRESS___.fetch ada.four_category_symbol
      ada.end_UI_frame
      NIL_
    end

    EXPRESS___ = {
      compound: :__express_compound,
      entitesque: :__express_entitesque,
      operation: :__express_operation,
      primitivesque: :__express_primitivesque,
    }

    def __express_compound
      @compound_frame.call @line_yielder  # imagine `express_compound_frame_into__`
      NIL_
    end

    def __express_operation
      @_top_frame.express_operation_frame__ self
      NIL_
    end

    def __express_entitesque
      @_top_frame.express_entitesque_frame__
      NIL_
    end

    def __express_primitivesque
      @primitive_frame.call @line_yielder  # imagine `express_primitive_frame_into_`
      NIL_
    end

    # -- for ancillaries (that are proxies)

    def expression_agent_for_niCLI_library__

      # we will *very likely* need to change either this method or all of
      # the code in iCLI involving producing an expression agent (all
      # here): it's not right to pass our pared down expag off to niCLI
      # and expect it to work under normal usage. #open (see) [#040]

      @expression_agent
    end

    # -- for ancillaries

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

    def top_frame
      @produce_top_frame.call
    end

    def main_view_controller
      self
    end

    attr_reader(
      :expression_agent,
      :line_yielder,  # [sa]
      :primitive_frame,
      :serr,
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
# #pending-rename: POSSIBLY to "main view controller"
