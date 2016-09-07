require_relative '../test-support'

module Skylab::DocTest::TestSupport

  describe "[dt] API - recurse intro" do

    TS_[ self ]
    use :fixture_files
    use :my_API

    it "`path` is a required parameter" do

      begin
        call_API :recurse, :filesystem, :_not_an_FS_
      rescue ::Skylab::Autonomous_Component_System::MissingRequiredParameters => e
      end

      e.message.include? "'recurse' is missing required parameter 'path'" or fail
    end

    context "against noent dir" do

      call_by do

        _dir = the_noent_directory_

        call(
          :recurse,
          :path, _dir,
          :filesystem, the_real_filesystem_,
        )
      end

      it "fails" do
        fails
      end

      it "emits" do
        expect_emission :error, :stat_error do |ev|
          _msg = black_and_white ev
          _msg.include? "No such file or directory -" or fail
        end
      end
    end

    context "whoopie list (test against self eek)" do

      call_by do

        _dir = sidesystem_path_

        call(
          :recurse,
          :path, _dir,
          :list, true,
          :filesystem, the_real_filesystem_,
        )
      end

      it "appears to succeed" do
        expect_trueish_result
      end

      it "no unexpected emissions" do
        expect_no_emissions
      end

      context "result.." do

        shared_subject :_array do

          a = root_ACS_result.to_a

          a.sort_by! do |uow|
            uow.asset_path.length
          end
          a
        end

        it "uow for probably shallower asset, test file DOES exit; is last thing" do

          uow = _array.fetch 0
          uow.asset_path || fail
          uow.test_path || fail
          uow.test_path_is_real && fail
        end

        it "uow for probably deeper asset, test file does NOT exist" do

          a = _array
          a.fetch(1).test_path_is_real || fail
          a.length == 2 || fail
        end
      end
    end

    h = { find_command_args: true }
    define_method :ignore_for_expect_event do
      h
    end
  end
end
# #tombstone: tests removed in this commit will have DNA brought back in a future commit.
# #tombstone: tested old enum meta-field
