module Skylab::Fields::TestSupport

  module Parameter

    def self.[] tcc

      tcc.extend self
      tcc.include Test_Context_Instance_Methods___
    end

    SM___ = -> do
      Home_::Parameter
    end

    def capture_emit_lines_
      define_method :_do_capture_emit_lines do
        true
      end
    end

    def with &b                   # define the class body you will use in
                                  # the frame.
      memo = nil

      build = -> do

        build = nil  # one call to this method corresponds to one class that
        # employs the user's edit. however, we effect the class lazily, the
        # first it is requested.

        memo = ::Class.new
        Parameter.const_set :"Guy_#{ Next_number___[] }", memo

        memo.class_exec do

          Home_::Parameter::Definer[ self ]

          include Definer_Instance_Methods___

          class_exec( & b )
        end
        NIL_
      end

      define_method :the_class_ do

        if build
          build[]
        end

        memo
      end
      nil
    end

    Next_number___ = -> do
      count = 0
      -> do
        count += 1
      end
    end.call

    module Test_Context_Instance_Methods___

      TestSupport_::Let[ self ]

      let :object do

        if _do_capture_emit_lines

          a = []
          @emit_lines_ = a

          the_class_.new do | * i_a, & ev_p |
            2 == i_a.length or fail
            :info == i_a.first or fail
            :emission == i_a.last or fail
            ev_p[ a ]
            NIL_
          end
        else
          the_class_.new
        end
      end

      def _do_capture_emit_lines
        false
      end

      define_method :subject_module_, SM___
    end

    module Definer_Instance_Methods___

      def initialize & oes_p
        if oes_p
          @on_event_selectively = oes_p
        end
      end

      def _with_client &b        # slated for improvement [#012]
        instance_exec( &b )
      end

      def parameter_label x, idx=nil  # [#hl-036] explains it all, somewhat

        if idx
          _idx_s = "[#{ idx }]"
        end

        _stem = if x.respond_to? :id2name
          Home_::Callback_::Name.via_variegated_symbol( x ).as_slug
        else
          x.name.as_slug  # errors please
        end

        "<#{ _stem }#{ _idx_s }>"  # was `em`
      end

      def send_error_string s

        @on_event_selectively.call :info, :emission do | y |
          y << s
        end

        NIL_
      end
    end

    def frame &b
      class_exec( & b )
    end
  end
end
