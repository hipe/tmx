require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] digraph node creation" do

    it "'node!' plain" do
      di = Home_::Digraph.new
      di.node! :waz
      expect( di.length ).to eql 1
      expect( di._a ).to eql %i( waz )
      di.node! :waz
      expect( di._a ).to eql %i( waz )
    end

    it "'node!' with flavor" do
      di = Home_::Digraph.new
      di.node! :waz, is: [ :wiff, :wengle ]
      di.node! :wengle, is: [ :waffle ]
      io = Home_.lib_.string_IO
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
      expect( _act ).to eql _exp
      waz = di.node! :waz
      wiff = di.node! :wiff
      weng = di.node! :wengle
      waff = di.node! :waffle
      expect( waz.is?( wiff ) ).to eql true
      expect( waz.is?( weng ) ).to eql true
      expect( waz.is?( waff ) ).to eql true
      expect( waff.is?( waz ) ).to eql false
    end
  end
end
