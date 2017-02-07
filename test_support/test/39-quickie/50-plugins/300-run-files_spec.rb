require_relative '../../test-support'

module Skylab::TestSupport::TestSupport

  describe "[ts] quickie - plugins - run files" do

    TS_[ self ]
    use :memoizer_methods
    use :quickie_plugins

    context "nasssstyyy.." do

      # - API

        it "loaded more than one file" do
          1 < _tuple[2] || fail
        end

        it "(would have) loaded this selfsame file" do
          _tuple[0] || fail
        end

        it "said how many it loaded" do
          a = _tuple
          _exp = "(ran tests in #{ a[2] } files)"
          a[1] == [ _exp ] || fail
        end

        shared_subject :_tuple do

          eek = __FILE__

          _dir = ::File.dirname eek

          call :run_files, :path, _dir

          msgs = nil
          expect :info, :expression, :number_of_files do |y|
            msgs = y
          end

          count = 0 ; yes = false
          main = -> _ do
            count += 1
          end
          see = -> path do
            count += 1
            if eek == path
              yes = true
              see = main
            end
          end

          @SEE = -> path do
            see[ path ]
          end

          expect_succeed

          [ yes, msgs, count ]
        end
      # -
    end

    def prepare_subject_API_invocation invo

      # touch "early" the subject plugin and hack 2 methods on it..

      _msvc = invo.instance_variable_get :@__tree_runner_microservice

      pi = _msvc.lazy_index.dereference_plugin_via_normal_symbol :run_files

      _rt = __build_fresh_runtime  # see
      p = -> { p = nil ; _rt }  # assert that it's only called once just because
      pi.send :define_singleton_method, :__quickie_runtime do
        p[]
      end

      # don't actually load the file but:

      see = remove_instance_variable :@SEE
      pi.send :define_singleton_method, :load do |path|
        see[ path ] ; nil
      end

      super
    end

    def __build_fresh_runtime

      # don't read from or write to the real life production runtime

      Home_::Quickie::Runtime___.define do |o|
        o.kernel_module = :_no_see_ts_
        o.toplevel_module = :_no_see_ts_
      end
    end

    # ==
  end
end
# #born years later
