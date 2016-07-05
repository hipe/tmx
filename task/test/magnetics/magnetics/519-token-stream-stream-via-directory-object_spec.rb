require_relative '../../test-support'

module Skylab::Task::TestSupport

  describe "[ta] magnetics - magnetics - token stream stream via directory object", wip: true do

    TS_[ self ]
    use :memoizer_methods

    it "parses on \"via\"" do
      o = _fetch 0
      o.slug_A == 'shomply-domply' or fail
      o.slugs_B == %w( plomply ) or fail
    end

    it "parses on \"and\"" do
      o = _fetch 1
      o.slug_A == 'joopie' or fail
      o.slugs_B == %w( proopie soopie ) or fail
    end

    it "if doesn't parse, is still represnted" do
      o = _fetch 2
      o.slug_A == 'jiggernaut' or fail
      o.slugs_B and fail
    end

    def _fetch d
      _a.fetch d
    end

    shared_subject :_a do

      o = begin_mock_FS_

      o.add_thing 'skerplumkin' do
        %w( . ..
          shomply-domply-via-plomply.rx
          joopie-via-proopie-and-soopie.rx
          jiggernaut.rx
        )
      end

      o = o.finish

      _st = subject_module_::Magnetics_::MeansStream_via_Path.new( 'skerplumkin', o ).execute
      _st.to_a
    end
  end
end
