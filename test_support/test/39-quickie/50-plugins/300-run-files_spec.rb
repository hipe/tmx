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
          _exp = "(#{ a[2] } files loaded)"
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

      pi = hack_that_one_plugin_of_invocation_to_use_this_runtime_ invo do
        build_fresh_dummy_runtime_
      end

      # don't actually load the file but:

      see = remove_instance_variable :@SEE
      pi.send :define_singleton_method, :load do |path|
        see[ path ] ; nil
      end

      super
    end

    # ==
  end
end
# #born years later
