require_relative '../test-support'

module Skylab::Basic::TestSupport::List

  describe "[ba] List" do

    it "that responds to `each_pair` via a flat list of name-value pairs" do
      ea = Basic_::List.build_each_pairable_via_even_iambic [ :a, :b, :c, :d ]
      ::Hash[ ea.each_pair.to_a ].should eql ( { a: :b, c: :d } )
    end
  end
end
