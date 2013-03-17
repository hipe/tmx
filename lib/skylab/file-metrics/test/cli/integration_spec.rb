require_relative 'test-support'

module Skylab::FileMetrics::TestSupport::CLI

  # Quickie.

  describe "#{ FileMetrics }::CLI - integration" do

    extend CLI_TestSupport

    context "lc" do

      desc 'give me `lc` here and now'
      argv 'lc', '[fm dir]'
      ptrn '2.3x3'
      it does do
        # (see [#007] - we do it for reasons)
        TestSupport::Services::FileUtils.cd FileMetrics.dir_pathname.to_s do
          invoke [ 'lc', '.' ]  # le dorky [#006]
          lines = convert_whole_err_string_to_unstylized_lines
          headers = headers_hack lines[0]
          headers.should eql( [ :file, :lines, :total_share, :max_share ] )
          cels = cels_hack lines[1]
          cels.shift.should eql( './cli.rb' )  # meh
          ( 50 .. 300 ).should be_include( expect_integer( cels.shift ) )
          expect_percent cels.shift
          expect_percent cels.shift, 100.0
          expect_pluses cels.shift, 16 .. 100
          cels.should be_empty
        end
      end
    end

    context "ext" do

      desc 'i want `ext` here now'
      argv 'ext', '[fm dir]'
      ptrn '2.3x3'
      expt_desc 'header looks good'

      it does do
        headers_hack( output_lines[0] ).should eql(
          [ :extension, :num_files, :total_share, :max_share ] )
      end

      it "first body line looks good" do
        line = output_lines[1]
        cel_a = line.strip.split( / +/ )
        cel_a.shift.should eql( '*.rb' )
        num = cel_a.shift
        num.should match( /\A\d+\z/ )
        ( 18 .. 18 ).should be_include( num.to_i )  # saying hello to the future
        expect_percent cel_a.shift
        expect_percent cel_a.shift, 100.0
        expect_pluses cel_a.shift, 16..100
        cel_a.should be_empty
      end

      it "final line looks good" do
        line_a = output_lines
        ( 4..6 ).should be_include(  line_a.length  )  # hello from the past
        line_a.last.should eql(  # will loosen up later #todo
          "(* only occuring once were: .one and .two)" )
      end

      -> do  # `output_lines`  - a memoizing cheat
        did = res = nil
        define_method :output_lines do
          if ! did
            did = true
            # self reflexive test ([#006]) that does a cd ([#007])
            TestSupport::Services::FileUtils.cd FileMetrics.dir_pathname.to_s do
              invoke [ 'ext', '.' ]
              res = convert_whole_err_string_to_unstylized_lines
            end
          end
          res
        end
      end.call
    end
  end
end
