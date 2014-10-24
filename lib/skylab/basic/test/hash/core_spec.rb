require_relative 'test-support'

module Skylab::Basic::TestSupport::Hash

  describe "[ba] Hash" do
    context "the loquacious default proc" do
      Sandbox_1 = Sandboxer.spawn
      it "can be used like so" do
        Sandbox_1.with self
        module Sandbox_1
          h = { foo: 'bar', biff: 'baz' }
          h.default_proc = Basic_::Hash.loquacious_default_proc.
            curry[ 'beefel' ]
          -> do
            h[ :luhrmann ]
          end.should raise_error( KeyError,
                       ::Regexp.new( "\\Ano\\ such\\ beefel\\ 'luhrmann'\\.\\ did\\ you\\ mean\\ 'foo'\\ or\\ 'biff'\\?\\z" ) )
        end
      end
    end
    context "read [#026] the hash narrative # #storypoint-105" do
      Sandbox_2 = Sandboxer.spawn
      it "but here's the gist of it" do
        Sandbox_2.with self
        module Sandbox_2
          h = { age: 2, name: "me" }
          name, age = Basic_::Hash.unpack_equal h, :name, :age
          name.should eql( "me" )
          age.should eql( 2 )
        end
      end
    end
  end
end
