require_relative 'test-support'

module Skylab::FileMetrics::TestSupport::CLI

  # Quickie - but NOTE it gets whacky b.c of ncurses!

  describe "#{ FileMetrics }::CLI - integration" do

    extend CLI_TestSupport

    floor = 14

    context "lc" do

      desc 'give me `lc` here and now'
      argv 'lc', '[fm dir]'
      ptrn '2.3x3'
      expt_desc "header / first line / summary line"

      memoize_output_lines do
        TestSupport::Services::FileUtils.cd FileMetrics.dir_pathname.to_s do
          invoke [ 'lc', '.' ]  # le dorky [#006], [#007]
        end
      end

      it "header" do
        headers_hack( output_lines[ 0 ] ).should eql(
          [ :file, :lines, :total_share, :max_share ]
        )
      end

      it "body" do
        arr = cels_hack output_lines[ 1 ]
        arr.length.should eql( 5 )
        fl, ln, pc1, pc2, lip = arr
        fl.should eql( './services/table.rb' )  # meh
        expect_integer ln, 50 .. 400
        expect_percent pc1
        expect_percent pc2, 100.0
        expect_pluses lip, floor..150
      end

      it "summary" do
        output_lines[ -1 ].should match( /\A +total: +\d{2} +\d{4} +\z/i )
      end
    end

    context "ext - lines:" do

      desc 'i want `ext` here now'
      argv 'ext', '[fm dir]'
      ptrn '2.3x3'
      expt_desc 'header looks good'

      memoize_output_lines do
        TestSupport::Services::FileUtils.cd FileMetrics.dir_pathname.to_s do
          invoke [ 'ext', '.' ]  # more dorky [#006], [#007]
        end
      end

      it "header" do
        headers_hack( output_lines[0] ).should eql(
          [ :extension, :num_files, :total_share, :max_share ] )
      end

      it "body" do
        ( 4..6 ).should be_include( output_lines.length )
        arr = cels_hack output_lines[ 1 ]
        arr.length.should eql( 5 )
        lbl, num, pc1, pc2, lip = arr
        lbl.should eql( '*.rb' )
        expect_integer num, 15..18  # greetings from the past
        expect_percent pc1
        expect_percent pc2, 100.0
        expect_pluses lip, floor..150
      end

      it "final" do
        output_lines[ -1 ].should eql(  # will loosen up later #todo
          "(* only occuring once were: .one and .two)" )
        # (note there are no summary lines for the ext report)
      end
    end

    context "dirs - lines:" do

      desc 'show me the `dirs`'
      argv 'dirs', '[fm dir]'
      ptrn '2.3x3'

      memoize_output_lines do
        TestSupport::Services::FileUtils.cd( FileMetrics.dir_pathname.to_s ) do
          invoke [ 'dirs', '.' ]  # still dorky [#006], [#007]
        end
      end

      it "header" do
        headers_hack( output_lines[0] ).should eql(
          [ :directory, :num_files, :num_lines, :total_share, :max_share ] )
      end

      it "body" do
        dr, nf, nl, ts, ms, lp = output_lines[1].strip.split( /(?!< ) +(?! )/ )
        dr.should eql( 'api' )
        expect_integer nf, 3..10
        expect_integer nl, 400..520  # hello from the past
        expect_percent ts
        expect_percent ms, 100.0
        expect_pluses lp, floor..150
      end

      it "sumary" do
        output_lines[ -1 ].should match( /\A +total: +\d{2,3} +\d{4} +\z/i )
      end
    end
  end
end
