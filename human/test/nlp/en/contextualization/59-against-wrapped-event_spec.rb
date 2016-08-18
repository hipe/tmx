require_relative '../../../test-support'

module Skylab::Human::TestSupport

  describe "[hu] NLP - EN - contextualization - againt wrapped event" do

    TS_Joist_[ self ]
    use :memoizer_methods
    use :NLP_EN_contextualization

    # :#here: at the moment these channels (first term) are ultimately
    # trumped by the trilean of the event, and effectively inert #c15n-spot-2

    it "neutral (EXPERIMENTAL DEFAULT IDIOM)" do
      _ = _lines :success, :ok, true, :is_completion, false  # #here
      _.should eql [ "while frobing widgetszzz, updated «/some/file» (123 bytes)\n" ]
    end

    it "success" do
      _ = _lines :error, :ok, true  # #here
      _.should eql [ "frobed widgetszzz: updated «/some/file» (123 bytes)\n" ]
    end

    it "failure" do
      _ = _lines :info, :ok, false  # #here
      _.should eql [ "couldn't frob widgetszzz because updated «/some/file» (123 bytes)\n" ]
    end

    def _lines sym, * a

      _o = _begin_expression sym, a
      _o.express_into []
    end

    def _begin_expression sym, a

      ev = __build_wrapped_event a

      _build_ev = -> do
        ev
      end

      o = subject_class_.begin

      o.given_emission [ sym, :_not_expresion_ ], & _build_ev

      _ea = common_expag_

      o.expression_agent = _ea
      o
    end

    def __build_wrapped_event a
      _ev = __build_initial_event a
      _we = __wrap_event _ev
      _we
    end

    def __wrap_event ev

      _nf = __build_legacy_name_structure
      _ = Common_::Event.wrap.signature _nf, ev
      _
    end

    def __build_legacy_name_structure

      # ::Skylab::Brazen::Actionesque::Name

      # the wrapping node does not require that we respond to
      # `inflected_noun`, but if we don't it steps into something much uglier

      o = XXX_Stub_Etc.new
      o.verb_lexeme = Home_::NLP::EN::POS::Verb[ 'frob' ]
      o.noun_lexeme = Home_::NLP::EN::POS::Noun[ 'widjit' ]
      o.inflected_noun = "widgetszzz"

      # the above noun_lexeme exists to show that it is not used - it shows
      # that the inflected_noun always trumps it. (this is so that "list"
      # "users", for example, always uses the plural noun.)

      o
    end

    def __build_initial_event a

      require 'skylab/system'  # ([hu] and [sy] are diametrically opposed!)

      _ = ::Skylab::System::Filesystem::Events::Wrote.new_with(
        :preterite_verb, 'updated',
        :bytes, 123,
        :path, '/some/file',
        * a,
      )

      _
    end

    XXX_Stub_Etc = ::Struct.new :inflected_noun, :noun_lexeme, :verb_lexeme
  end
end
