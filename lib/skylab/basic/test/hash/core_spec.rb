require_relative 'test-support'

module Skylab::Basic::TestSupport::Hash

  describe "[ba] Hash" do
    context "the loquacious default proc" do
      Sandbox_1 = Sandboxer.spawn
      it "can be used like so" do
        Sandbox_1.with self
        module Sandbox_1
          h = { foo: 'bar', biff: 'baz' }
          h.default_proc = Basic::Hash::Loquacious_default_proc.
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
          name, age = Basic::Hash::FUN::Unpack_equal[ h, :name, :age ]
          name.should eql( "me" )
          age.should eql( 2 )
        end
      end
    end
    context "'pairs_at' is like 'values_at' and 'each_pair' combined" do
      Sandbox_3 = Sandboxer.spawn
      it "and note that it methodizes the names as a rule" do
        Sandbox_3.with self
        module Sandbox_3
          fun = Basic::Hash::FUN
          _a = fun.pairs_at( :unpack_subset ).to_a
          _a.should eql( [ [ :unpack_subset, fun::Unpack_subset ] ] )
        end
      end
    end
  end
end
