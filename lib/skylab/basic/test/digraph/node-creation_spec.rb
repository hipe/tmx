require_relative 'test-support'

module Skylab::Basic::TestSupport::Digraph::Holes__

  ::Skylab::Basic::TestSupport::Digraph[ self ]

  include Constants

  extend TestSupport_::Quickie

  describe "[ba] digraph node creation" do

    it "'node!' plain" do
      di = Basic_::Digraph.new
      di.node! :waz
      di.length.should eql 1
      di._a.should eql %i( waz )
      di.node! :waz
      di._a.should eql %i( waz )
    end

    it "'node!' with flavor" do
      di = Basic_::Digraph.new
      di.node! :waz, is: [ :wiff, :wengle ]
      di.node! :wengle, is: [ :waffle ]
      io = Basic_::Lib_::String_IO[]
      di.describe_digraph :IO, io, :with_spaces, :with_solos
      _act = io.string
      _exp = <<-O.unindent.chop
        wiff
        waz -> wiff
        wengle
        waz -> wengle
        waffle
        wengle -> waffle
      O
      _act.should eql _exp
      waz = di.node! :waz
      wiff = di.node! :wiff
      weng = di.node! :wengle
      waff = di.node! :waffle
      waz.is?( wiff ).should eql true
      waz.is?( weng ).should eql true
      waz.is?( waff ).should eql true
      waff.is?( waz ).should eql false
    end
  end
end
