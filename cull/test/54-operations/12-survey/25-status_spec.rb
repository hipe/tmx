require_relative '../../test-support'

module Skylab::Cull::TestSupport

  describe "[cu] operations - survey - status" do

    TS_[ self ]
    use :memoizer_methods
    use :want_event

# (1/N)
    it "with a noent path" do
      against ::File.join TS_.dir_path, 'no-ent'
      want_not_OK_event_ :start_directory_does_not_exist
      want_fail
    end

# (2/N)
    it "with a path that is a file" do
      against __FILE__
      want_not_OK_event :start_directory_is_not_directory
      want_fail
    end

# (3/N)
    it "with a path that is a directory but workspace not found" do
      against TestSupport_::Fixtures.directory :empty_esque_directory
      want_not_OK_event :resource_not_found
      want_fail
    end

# (4/N)
    it "with a workspace with no datappoints" do
      against fixture_directory_ :freshly_initted
      scn = @result
      x = scn.gets
      x.should be_nil
    end

#==(ADDENDUM

    context "when config file exists with strange section name" do

      it "fails" do
        _fails
      end

      it "explains" do
        _actual = _tuple.first
        _actual == [ 'the section "chiwetel ejiofor" does not correspond to any known association.' ] || fail
      end

      shared_subject :_tuple do
        x = call_API(
          * _subject_action,
          :path, fixture_directory_( :strange_section ),
        )
        a = []
        want :error, :expression, :unrecognized_section_name do |y|
          a.push y
        end
        a.push x
      end
    end

    # (for no particular reason except history, the error case of having
    # multiple sections associated with a singleton association is covered
    # over at #cov1.6)

    context "when config file exists, entity section has issues within the section" do

      it "fails" do
        _fails
      end

      it "whines about table number" do
        _actual = _tuple.first
        _actual == [ "table number is not integer" ] || fail
      end

      it "whines about unrec assoc" do
        _actual = _tuple[1]
        _actual == [ '"upstream" doesn\'t have this association: "chiwetel ejiofor"' ] || fail
      end

      shared_subject :_tuple do

        x = call_API(
          * _subject_action,
          :path, fixture_directory_( :upstream_with_strange_associations ),
        )

        a = []
        want :error, :expression, :primitive_type_error do |y|
          a.push y
        end

        want :error, :expression, :unrecognized_associations do |y|
          a.push y
        end

        a.push x
      end
    end

#===)

# (5/N)
    it "with an upstream 'foo'" do
      # #cov1.3
      count = 0
      y = []
      against fixture_directory_ :upstream_foo
      scn = @result
      expag = expression_agent_for_want_emission_normally
      begin
        o = scn.gets
        o || break
        count += 1
        o.express_into_under y, expag
        redo
      end while above
      count.should eql 1
      y.first =~ /\Aupstream \(val "file:\.\./ || fail
    end

    # -- assert

    def _fails
      _tuple.last.nil? || fail
    end

    # -- setup

    def against path
      call_API :survey, :status, :path, path
    end

    def _subject_action
      [ :survey, :status ]
    end

    # ==
    # ==
  end
end
