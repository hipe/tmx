require_relative 'test-support'

module Skylab::FileMetrics::TestSupport::CLI

  # Quickie.

  describe "#{ FileMetrics }::CLI - integration" do

    extend CLI_TestSupport

    context "ext" do

      desc 'run it here now'
      argv 'ext', '[fm dir]'
      ptrn '2.3x3'

      it "header looks good" do
        line = output_lines.first
        cel_a = line.strip.split( / +/ ).map do |s|
          s.downcase.gsub( ' ', '_' ).intern
        end
        cel_a.should eql(  # yikes, meh
          [:extension, :num, :files, :total, :share, :max, :share] )
     end

      it "first body line looks good" do
        line = output_lines[1]
        cel_a = line.strip.split( / +/ )
        cel_a.shift.should eql( '*.rb' )
        num = cel_a.shift
        num.should match( /\A\d+\z/ )
        ( 18 .. 18 ).should be_include( num.to_i )  # saying hello to the future
        pct = nil
        2.times do
          pct = cel_a.shift
          pct.should match( /\A\d{2,3}\.\d\d%\z/ )
        end
        pct.should eql( '100.00%' )  # stahp
        pluses = cel_a.shift
        cel_a.should be_empty
        pluses.should match( /\A\+{30,100}\z/ )  # you makea me angry
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
            invoke [ 'ext', FileMetrics.dir_pathname.to_s ]  # le dorky
            x = whole_err_string
            str = Headless::CLI::Pen::FUN.unstylize_stylized[ x ]
            res = str.split "\n"
          end
          res
        end
      end.call
    end
  end
end
