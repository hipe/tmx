module Skylab::Fields::TestSupport

  module Parameter

    def self.[] tcc

      tcc.extend self
      tcc.include Test_Context_Instance_Methods___
    end

    def self.Frookie
      Frookie_class___[]
    end

    SM___ = -> do
      Home_::Parameter
    end

    def frame &b
      class_exec( & b )
    end

    def spy_on_events_

      define_method :_do_spy_on_events do
        true
      end

      TS_::Expect_Event[ self ]
    end

    def with &b                   # define the class body you will use in
                                  # the frame.
      memo = nil

      build = -> do_spy do

        build = nil  # one call to this method corresponds to one class that
        # employs the user's edit. however, we effect the class lazily, the
        # first it is requested.

        memo = ::Class.new
        Parameter.const_set :"Guy_#{ Next_number___[] }", memo

        memo.class_exec do

          Home_::Parameter::Definer[ self ]

          if do_spy
            define_method :initialize do | oes_p |
              @on_event_selectively = oes_p
            end
          end

          class_exec( & b )
        end
        NIL_
      end

      define_method :the_class_ do

        if build
          build[ _do_spy_on_events ]
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

      let :object_ do

        if _do_spy_on_events

          the_class_.new handle_event_selectively
        else
          the_class_.new
        end
      end

      def _do_spy_on_events
        false
      end

      def force_read_ sym, o
        o.send :fetch, sym
      end

      def force_write_ x, sym, o
        o.send :[]=, sym, x
      end

      def expect_unknown_ sym, obj

        known = true
        obj.send :fetch, sym do
          known = false
        end
        if known
          fail __say_expected_unknown sym
        end
      end

      def __say_expected_unknown sym
        "expected '#{ sym }' to be unknown"
      end

      define_method :subject_module_, SM___
    end

    Frookie_class___ = -> do
      p = -> do
        class Frookie < Home_::Parameter

          def when__perthnerm__
            sym = @writer_method_name or fail
            @entity_model.module_exec do

              alias_method :item_writer_after_perthnerm, sym
              define_method sym do | x |
                if x
                  x.respond_to? :ascii_only? or raise ::ArgumentError
                  item_writer_after_perthnerm ::Pathname.new x
                else
                  item_writer_after_perthnerm x
                end
              end
            end
            true  # KEEP_PARSING_
          end
        end
        p = -> do
          Frookie
        end
        Frookie
      end
      -> { p[] }
    end.call
  end
end
