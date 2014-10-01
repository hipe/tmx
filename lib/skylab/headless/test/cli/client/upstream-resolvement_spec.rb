require_relative 'test-support'

module Skylab::Headless::TestSupport::CLI::Client

  describe "[hl] CLI client upstream resolvement" do

    extend TS__

    context "one - not wired for upstream resolvement" do

      with_client_class do
        class Foo_UR
          Headless_::CLI::Client[ self ]
        private
          def default_action_i ; :hi end
          def hi flerp
            @IO_adapter.errstream.puts "ok: #{ flerp }"
            :_ok_
          end
          self
        end
      end

      it "loads" do
      end

      it "bulids" do
        client
      end

      it "0)   invokes - x" do
        invoke
        expect :styled, "expecting: <flerp>"
        expect_result_for_failure
      end

      it "1.3) invokes - o" do
        invoke 'hi'
        expect "ok: hi"
        expect_no_more_serr_lines
        @result.should eql :_ok_
      end
    end

    context "two - wired for upstream resolvement" do
      with_client_class do
        class Bar_UR
          Headless_::CLI::Client[ self ]
          def default_action_i ; :gerp end
          def gerp input_file_nombre=nil
            io = @IO_adapter.instream  ; m = []
            while (( line = io.gets ))
              m << line.chomp!
            end
            emit_info_line "winrar:(#{ m * '**' })"
            :_wazzle_
          end
        private
          def resolve_upstream_status_tuple
            resolve_instream_status_tuple
          end
          self
        end
      end

      it "no arg - x" do
        invoke
        expect :styled, /\Aexpecting:? <input-file-nombre>\z/
        expect_failed
      end

      it "file not found - x" do
        from_workdir do
          invoke 'not-there.txt'
        end
        expect :styled, '<input-file-nombre> not found: not-there.txt'
        expect_failed
      end

      it "is not file - x" do
        workdir.touch_r "#{ MAZZLE_DAZZLE__ }/"
        from_workdir do
          invoke MAZZLE_DAZZLE__
        end
        expect :styled,
          /\binput.file.nombre[^ ]* is directory: mazzle-dazzle\b/
        expect_failed
      end
      MAZZLE_DAZZLE__ = 'mazzle-dazzle'

      it "money - o" do
        workdir.write FIZZLE_BIZZLE__, "wiz\nwaz\n"  # (pn)
        from_workdir do
          invoke FIZZLE_BIZZLE__
        end
        expect 'winrar:(wiz**waz)'
        expect_no_more_serr_lines
        @result.should eql :_wazzle_
      end
      FIZZLE_BIZZLE__ = 'fizzle/bizzle.txt'

      context "with STDIN and filename" do

        def stdin_spy
          TestSupport_::IO::Spy::Triad::MOCK_NONINTERACTIVE_STDIN
        end

        it "complains of ambiguity before checking for file existence - x" do
          invoke 'whatever'
          _exp = <<-HERE.gsub( %r(\n^[ ]+), ' ' ).strip!
            cannot resolve ambiguous upstream modality paradigms --
            both STDIN and <input-file-nombre> appear to be present.
          HERE
          expect :styled, _exp
          expect_failed
        end
      end

      context "with STDIN only" do

        let :stdin_spy do
          TestSupport_::IO::Spy::Triad::Mock_Noninteractive_STDIN.
            new [ "fiz\n", "faz\n" ]
        end

        it "money - o" do
          invoke
          expect 'winrar:(fiz**faz)'
          @result.should eql :_wazzle_
        end
      end
    end
  end
end
