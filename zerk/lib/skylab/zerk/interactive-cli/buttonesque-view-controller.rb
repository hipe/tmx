module Skylab::Zerk

  class InteractiveCLI

  class ButtonesqueViewController

    # specifically so that custom views can work with buttonesques in
    # a more straightforward way - no loadable references, just labels and
    # event callbacks. (maybe merge later..)

    class << self

      def begin_frame
        Here_::Buttonesque_Expression_Adapter_::Frame.begin
      end

      def interpret s, o
        _ = Here_::Buttonesque_Interpretation_Adapter_[ s, o ]
        _
      end
    end  # >>

    def initialize * x_a

      st = Scanner_[ x_a ]
      while st.unparsed_exists
        send :"#{ st.gets_one }=", st
      end

      @_is_avaiable_proc ||= NILADIC_TRUTH_
    end

    # --
    private

    def hotstring_delineation= st
      _s_a = st.gets_one
      _ = Here_::Buttonesque_Expression_Adapter_.new( * _s_a, self )
      @custom_hotstring_structure = _ ; nil
    end

    def is_available= st  # #during #milestone-7 or..
      @_is_avaiable_proc = st.gets_one ; nil
    end

    def name_symbol= st
      sym = st.gets_one
      @_name_p = -> do
        nf = Common_::Name.via_variegated_symbol sym
        @_name_p = -> do
          nf
        end
        nf
      end ; nil
    end

    def name_symbol_proc= st
      cache = {}
      name_sym_p = st.gets_one
      @_name_p = -> do
        sym = name_sym_p.call
        _ = cache.fetch sym do
          x = Common_::Name.via_variegated_symbol sym
          cache[ sym ] = x
          x
        end
        _
      end ; nil
    end

    def on_press= st
      @on_press = st.gets_one ; nil
    end

    # --
    public

    def name
      @_name_p.call
    end

    def button_is_available
      @_is_avaiable_proc.call
    end

    attr_reader(
      :custom_hotstring_structure,
      :on_press,
    )

    NILADIC_TRUTH_ = -> { true }
  end

  end
end
