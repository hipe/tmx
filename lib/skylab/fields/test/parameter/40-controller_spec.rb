require_relative '../test-support'

module Skylab::Fields::TestSupport

  describe "[fi] P - controller" do

    extend TS_
    use :parameter
    use :expect_event

    it "loads" do
      Home_::Parameter::Controller
    end

    _COMMON_SETUP = -> do

      meta_param :required, :boolean

      define_method :normulize,
        Home_::Parameter::Controller::NORMALIZE_METHOD

      attr_accessor :on_event_selectively
    end

    context "missing requireds" do

      with do

        module_exec( & _COMMON_SETUP )

        param :first_name, :writer
        param :last_name, :writer, :required
        param :soc, :writer, :required
      end

      frame do

        it "when missing" do

          o = _object
          _x = o.normulize

          expect_not_OK_event :missing,
            /\Aguy-\d+ parameter missing the required parameters #{
              }'last-name' and 'soc'\z/

          expect_no_more_events

          _x.should eql false
        end

        it "when none missing" do

          o = _object
          o.last_name = false  # treated as required
          o.soc = :yeah
          _x = o.normulize

          expect_no_events

          _x.should eql true
        end
      end
    end

    context "defaulting" do

      with do

        module_exec( & _COMMON_SETUP )

        param :a, :writer, :default, :one
        param :b, :writer
        param :c, :writer, :default, :three

      end

      it "doesn't overwrite already provided (non-nil) values" do

        o = _object
        o.a = false
        o.c = :hi

        o.normulize.should eql true
        expect_no_events

        force_read_( :a, o ).should eql false
        force_read_( :c, o ).should eql :hi
      end

      it "does default only one nil value" do

        o = _object
        o.a = :hello
        o.b = :howdy

        o.instance_variable_defined?( :@c ).should eql false

        o.normulize.should eql true
        expect_no_events

        force_read_( :a, o ).should eql :hello
        force_read_( :b, o ).should eql :howdy
        force_read_( :c, o ).should eql :three
      end

      it "does default all nil values" do

        o = _object
        o.a = nil

        o.normulize.should eql true
        expect_no_events

        force_read_( :a, o ).should eql :one
        force_read_( :c, o ).should eql :three
      end
    end

    context "synthesis" do

      with do

        module_exec( & _COMMON_SETUP )

        param :a
        param :b, :required
        param :c, :default, :three
        param :d, :required, :default, :four

      end

      it "when ok" do

        o = _object
        o.instance_variable_set :@b, true

        o.normulize.should eql true
        expect_no_events

        o.instance_variable_get( :@c ).should eql :three
        o.instance_variable_get( :@d ).should eql :four
      end

      it "when missing (note all defaulting is effected regardless)" do

        o = _object

        o.normulize.should eql false

        _ev = expect_not_OK_event :missing
        a = _ev.parameters

        a.length.should eql 1
        a.first.name_symbol.should eql :b

        expect_no_more_events

        o.instance_variable_get( :@c ).should eql :three
        o.instance_variable_get( :@d ).should eql :four
      end
    end

    def _object

      o = object_
      o.on_event_selectively = handle_event_selectively
      o
    end

    def expression_agent_for_expect_event
      Home_.lib_.brazen::API.expression_agent_instance
    end
  end
end
