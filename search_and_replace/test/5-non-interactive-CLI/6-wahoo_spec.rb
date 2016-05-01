require_relative '../test-support'

module Skylab::SearchAndReplace::TestSupport

  describe "[sa] non-interactive CLI - wahoo" do

    TS_[ self ]
    use :zerk_help_screens

    # when faced with 3 extremes:
    #
    #   1) don't test modality integration at all
    #
    #   2) stub it out entirely (system calls, maybe even filesystem (but eew))
    #
    #   3) create a real repository like we did in [#024]
    #
    # , we chose none of them. instead, we test against a *real* repository
    # with no stubbing and no creating of repositories. but how, you ask?

    context "(context)" do

      given do

        path = my_fixture_tree_ '4-egads'

        require 'open3'
        i, o, e, w = ::Open3.popen3 'bash', chdir: path  # if you change path, LOOK
        i.puts "echo 'wazoozle' > not-versioned.orange"
        i.puts "echo 'hi' >> three-lines.txt"

        state = argv( 'search', 'replace',
          '--ruby-regexp', '/wazoozle/i',
          '-p', path,
          '--fil', '*.txt', '--filen', '*.orange',
          'MAH-NOOZLE',
        )

        _path = ::File.join path, 'some-orange.orange'
        _content = ::File.read _path

        # we do our own cleanup *in* this test eek

        i.puts "rm not-versioned.orange"
        i.puts "git checkout -- ."  # LOOK
        i.close
        e.gets and fail
        o.gets and fail
        w.value.exitstatus.nonzero? and fail

        state.freeform_x = _content

        state
      end

      it "exitstatus was failure because skipped some files with changes" do

        expect_exitstatus_for :component_rejected_request
      end

      it "no summary (only 3 content lines) for now because of simplified etc" do

        _interesting_lines.length == 3 or fail
      end

      it "skipped file that was not under version control" do

        _line = _interesting_lines[ :not_versioned ]
        _line.first_half == 'skipping because file is not under version control' or fail
      end

      it "wrote file that was under VCS with no changes" do

        _line = _interesting_lines[ :some_orange ]
        _line.first_half == "wrote 2 changes (125 bytes)" or fail
      end

      it "skipped file that was under VCS with changes" do

        _line = _interesting_lines[ :three_lines ]
        _line.first_half =~ %r(\Askipping because file changed since\b) or fail
      end

      shared_subject :_interesting_lines do

        X_niCLI_Wahoo = ::Struct.new :first_half, :path

        lines = niCLI_state.lines

        rx = %r(\A(.+) - (.+)$)
        DASH_ = '-' ; UNDERSCORE_ = '_'

        bx = Callback_::Box.new

        # while #open [#028] - manually ignore this verbose output - start at  2

        ( 2 ... lines.length ).each do |d|

          md = rx.match lines.fetch( d ).string
          sct = X_niCLI_Wahoo.new( * md.captures )

          s = ::File.basename sct.path
          s = s[ 0 ... - ( ::File.extname s ).length ]
          _k = s.gsub( DASH_, UNDERSCORE_ ).intern

          bx.add _k, sct
        end

        bx
      end
    end

    def subject_CLI
      Home_::CLI
    end
  end
end
