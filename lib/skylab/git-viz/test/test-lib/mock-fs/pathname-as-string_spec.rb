require_relative 'test-support'

module Skylab::GitViz::TestSupport::Test_Lib::Mock_FS

  describe "[gv] test lib - mock FS - pathname as string" do

    extend TS_

    it 'loads' do
      Mock_FS_Parent_Module__::Mock_FS
    end

    context "employment" do

      before :all do
        class Employer_STR
          Mock_FS_Parent_Module__::Mock_FS[ self ]
        end
      end

      it "employ it on (e.g a test context class) with `Mock_FS[cls]`" do
        m_i = :mock_pathname ; mod = Employer_STR
        mod.private_method_defined? m_i or mod.method_defined? m_i or fail
      end
    end

    it "usage - you must define the path method" do

      test_context = _one_such_instance

      begin
        test_context.mock_pathname :x
      rescue ::NoMethodError => e
      end

      e.name.should eql :manifest_path_for_mock_FS
    end

    it "usage - you must define the cache method" do

      test_context = _one_such_instance

      def test_context.manifest_path_for_mock_FS
      end

      begin
        test_context.mock_pathname :x
      rescue ::NoMethodError => e
      end

      e.name.should eql :cache_hash_for_mock_FS
    end

    def _one_such_instance

      ::Class.new.class_exec do
        Mock_FS_Parent_Module__::Mock_FS[ self ]
        self
      end.new
    end

    context "usage - working with pathnames - absolute/relative" do

      before :all do

        class Eg_Test_Eg_Context_STR

          Mock_FS_Parent_Module__::Mock_FS[ self ]

          define_method :cache_hash_for_mock_FS, BUILD_CACHE_METHOD_[]

          def manifest_path_for_mock_FS
            COMMON_MOCK_FS_MANIFEST_PATH_
          end
        end
      end

      def test_context_class
        Eg_Test_Eg_Context_STR
      end

      it "fugue - both ::Pn and pathnme must be constructed with string-ish" do
        expect_same_type_coercion_error do
          ::Pathname.new nil
        end
        expect_same_type_coercion_error do
          test_context.mock_pathname nil
        end
      end

      def expect_same_type_coercion_error &p
        p.should raise_error ::TypeError, "no implicit conversion of #{
          }nil into String"
      end

      it "pathnames are secretly memoized" do
        pn = test_context.mock_pathname 'anything'
        pn_ = test_context.mock_pathname 'anything'
        pn.object_id.should eql pn_.object_id
      end

      it "simple absolute is absolute, not relative" do
        @pn = simple_absolute
        expect_absolute
      end

      memoize :simple_absolute do
        build_pathname_from_string '/foo'
      end

      it "compound absolute is absolute, not relative" do
        @pn = compound_absolute
        expect_absolute
      end

      memoize :compound_absolute do
        build_pathname_from_string '/foo/bar'
      end

      it "simple relative is relative, not absolute" do
        @pn = simple_relative
        expect_relative
      end

      memoize :simple_relative do
        build_pathname_from_string 'biz'
      end

      it "compound relative is relative, not absolute" do
        @pn = compound_relative
        expect_relative
      end

      memoize :compound_relative do
        build_pathname_from_string 'biz/baz'
      end

      it "empty string is relative" do
        @pn = empty_string_pathname
        expect_relative
      end

      memoize :empty_string_pathname do
        build_pathname_from_string ''
      end

      def build_pathname_from_string str
        test_context.mock_pathname str
      end
    end

    context "join (fugues)" do

      it "<# \"/foo\" >.join \"bar\"" do
        fugue '/foo' do |pn|
          pn.join 'bar'
        end
      end

      it "<# \"foo/bar/bif/baz\" >.join '../../wazoozle'" do
        fugue 'foo/bar/bif/baz' do |pn|
          pn.join '../../wazoozle'
        end
      end

      it "<# 'a/b/c' >.join '/z'" do
        fugue 'a/b/c' do |pn|
          pn.join '/z'
        end
      end
    end

    it "`relative_path_from`" do
      from_pn = ::Pathname.new '/abc/lmn/op'
      fugue '/abc/def/ghi' do |pn|
        pn.relative_path_from from_pn
      end
    end
  end
end
