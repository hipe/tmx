module Skylab::TMX::TestSupport

  module Models

    Reactions = -> tcc do
      Common_.test_support::Expect_Event[ tcc ]
      Building[ tcc ]
    end

    # <-

  module Building

    def self.[] tcc
      tcc.include self
    end

    def build_and_call_ * x_a

      block_given? and self._NOT_YET

      _o = front_
      @result = _o.call( * x_a, & event_log.handle_event_selectively )
      NIL_
    end

    def build_mock_unbound_ sym
      TS_::Mocks::Unbound.new sym
    end

    define_method :build_shanoozle_into_ do | mod |

      # into the argument module build what is needed to make it a minimal
      # reactive model host, complete with one action and a running kernel

      bz = Home_.lib_.brazen

      mod::Models_ = ::Module.new  # (before next)

      mod::API = ::Module.new
      mod::API.send :define_singleton_method, :application_kernel_, -> do
        ak = bz::Kernel.new mod
        -> do
          ak
        end
      end.call

      model = ::Module.new

      mod::Models_::No_See = model

      model::Actions = ::Module.new

      cls = ::Class.new bz::Action

      model::Actions::Shanoozle = cls

      cls.is_promoted = true

      cls
    end

    def subject_module_
      Home_::Models_::Reactive_Model_Dispatcher
    end

    def init_front_with_box_ fr, bx

      fr.fast_lookup = -> nf do
        bx[ nf.as_lowercase_with_underscores_symbol ]
      end

      fr.unbound_stream_builder = -> do
        bx.to_value_stream
      end
      NIL_
    end
  end
# ->
  end
end
