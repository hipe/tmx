require_relative 'file/test-support'

module Skylab::Snag::TestSupport::Models::Manifest::File

  # has Quickie

  describe "[sg] models manifest file" do

    extend File_TestSupport

    it "when file not found lines.each - raises raw runtime error lazily" do
      file = Snag_::Models::Manifest.build_file fixture_pathname 'not-there.txt'
      enum = file.normalized_lines # note it does not raise even yet
      -> do
        enum.each do |line|
        end
      end.should raise_error( ::Errno::ENOENT,
                             %r{\ANo such file[^-]+ - /.+not-there\.txt\z} )
    end

    context "when file found" do

      let :file do
        file = Snag_::Models::Manifest.build_file fixture_pathname 'foo.txt'
        file
      end

      # if mutex is `false` it was never touched
      # if mutex is `true` file is open
      # if mutex is `nil` file was opened then closed
      def mutex
        file.instance_variable_get '@file_mutex'
      end

      # --*--

      it "when not interrupted, `lines` reads each line, chomped - closes" do
        mutex.should eql(false)
        file.normalized_lines.to_a.should eql( %w(alpha beta gamma) )
        mutex.should eql(nil)
      end


      it "when interrupted with a `detect`, `lines` - closes" do
        mutex.should eql(false)
        line = file.normalized_lines.detect do |lin|
          mutex.should eql(true)
          'beta' == lin
        end
        mutex.should eql(nil)
        line.should eql('beta')
      end


      it "when interrupted with a break from each - closes" do
        mutex.should eql(false)
        found = false
        file.normalized_lines.each do |lin|
          mutex.should eql(true)
          if 'beta' == lin
            found = true
            break
          end
        end
        mutex.should eql(nil)
        found.should eql(true)
      end
    end
  end
end
