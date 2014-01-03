require_relative 'test-support'

module Skylab::TestSupport::TestSupport::Regret::API::Actions::Intermediates

  ::Skylab::TestSupport::TestSupport::Regret::API::Actions[ self ]

  include CONSTANTS

  TestSupport = ::Skylab::TestSupport

  extend TestSupport::Quickie

  Sandboxer = TestSupport::Sandbox::Spawner.new

  describe "Skylab::TestSupport::Regret::API::Actions::Intermediates" do
    context "we can access the API" do
      Sandbox_1 = Sandboxer.spawn
      before :all do
        Sandbox_1.with self
        module Sandbox_1
          
          HOME_ = TestSupport::Regret.dir_pathname

          # ( ignore this ENTIRE TEST SUPPORT INSIDE YOUR DOC-TEST )
          Intr_ = -> *a do
            io = TestSupport::IO::Spy::Triad.new nil
            # io.debug!
            h = { out: io.outstream, err: io.errstream }
            0.step(a.length-1, 2).each { |d| h[a[d]] = a[d+1] }
            r = TestSupport::Regret::API.invoke :intermediates, h
            out_a = io.outstream.string.split "\n"
            err_a = io.errstream.string.split "\n"
            [ r, out_a, err_a ]
          end
        end
      end
      it "through the `invoke` method" do
        Sandbox_1.with self
        module Sandbox_1
          TestSupport::Regret::API.respond_to?( :invoke ).should eql( true )
        end
      end
      it "when the (absolute) path is not found" do
        Sandbox_1.with self
        module Sandbox_1
          in_pn = HOME_.join( 'nope' )  # abspaths
          r, o, e = Intr_[ :path, in_pn ]
          o.length.should eql( 0 )
          e.shift.should eql( "not found: #{ in_pn }" )
          e.shift.should eql( "can't make intermediate test files without a start node." )
          r.should eql( false )
        end
      end
      it "when it is not an absoulte path, borkage" do
        Sandbox_1.with self
        module Sandbox_1
          -> do
            Intr_[ :path, 'nope' ]
          end.should raise_error( RuntimeError,
                       ::Regexp.new( "\\Awe\\ don't\\ want\\ to\\ mess\\ with\\ relpaths" ) )
        end
      end
      it "when it is an existant absolute path - works (dry run)" do
        Sandbox_1.with self
        module Sandbox_1
          in_pn = HOME_.join( 'api/actions/doc-test/templos--/quickie/context--' )
          r, o, e = Intr_[ :path, in_pn, :vtuple, 4, :is_dry_run, true ]
          s = e * "\n"
          matches = -> rx do
            rx =~ s or fail "string did not contain #{ rx }"
            true
          end
          o.length.should eql( 0 )
          r.should eql( true )
          yes = e.include?(
            "(verbosity level 3 is the highest. ignoring 1 of the verboses.)" )
          yes.should eql( true )
          matches[ /yep i see it there.+context--$/ ].should eql( true )
          s.scan( /^exists - / ).length.should eql( 5 )
          big_rx =  %r|^\(writing .+templos--/quickie/test-support\.rb #{
            }\.\. done \(\d+ fake bytes\)\)$|
          matches[ big_rx ].should eql( true )
          matches[ %r|^mkdir .+templos--/quickie/context--| ].should eql( true )
          e.pop.should eql( 'ok.' )
        end
      end
      it "content looks ok" do
        Sandbox_1.with self
        module Sandbox_1
          opn =  TestSupport::TestSupport.dir_pathname.
            join( 'regret/code-fixtures-' )
          remove_entry_secure = -> do
            TestSupport::Services::FileUtils.remove_entry_secure opn.to_s
          end
          opn.exist? and remove_entry_secure[]
          in_pn = HOME_.join( 'code-fixtures-/asap/whootenany.rb' )
          r, o, e = Intr_[ :path, in_pn ]
          r.should eql( true )
          o.length.should eql( 0 )
          these = e.grep( /\A\(writing/ )
          rx = /\A\(writing #{ ::Regexp.escape opn.to_s }/
          same = e.grep rx
          these.length.nonzero? or fail "sanity - no match?"
          these.length.should eql( same.length )
          contents = opn.join( 'asap/whootenany/test-support.rb' ).read
          ok = contents.include?(
            'TestSupport::Regret::Code_Fixtures_::ASAP::Whootenany' )
          ok.should eql( true )
          remove_entry_secure[]
        end
      end
    end
  end
end
