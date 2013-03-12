require_relative '../test-support'

module Skylab::Porcelain::TestSupport::Bleeding::Namespace

  ::Skylab::Porcelain::TestSupport::Bleeding[ Namespace_TestSupport = self ]

  include CONSTANTS  # so you can say b. from there

  Bleeding = Bleeding  # so you can reach b. from inside a class defintion
                       # inside a memoized `let` in a spec.

  module ModuleMethods

    last_number = 0

    define_method :namespace do |&blk|
      define_method :_ordinary_module, & MetaHell::FUN.memoize[ -> do
        mod = ::Module.new  # (you're still not in the text instance ctxt btw)
        Namespace_TestSupport.const_set "Xyzzy#{ last_number += 1 }", mod
        mod.module_exec(& blk )
        mod
      end ]  # (note that there is an i.m `namespace` that will call above)
    end

    def token token
      define_method :token do token end
    end

    def events &should_be
      let :subject do  # let the subject be the resultant events!
        normalized_event_sheets
      end
      specify(& should_be )
    end

    def result &should_be
      let :subject do
        result
      end
      specify(& should_be )
    end
  end

  module InstanceMethods

    def normalized_event_sheets
      _execution[:normalized_event_sheets]
    end

    def result
      _execution[:result]
    end

    def namespace
      _ordinary_module
    end

    def _execution
      @_execution ||= begin
        mod = _ordinary_module
        act = Bleeding::Namespace::Inferred.new mod
        tok = self.token
        spy = PubSub_TestSupport::Emit_Spy.new
        spy.debug = -> { do_debug }
        result = act.find tok do |o|
          o.on_ambiguous { |txt| spy.emit :ambiguous, txt }
          o.on_not_found { |txt| spy.emit :not_found, txt }
          o.on_not_provided { |txt| spy.emit :not_provided, txt }
        end
        { normalized_event_sheets: spy.delete_emission_a, result: result }
      end
    end
  end
end
