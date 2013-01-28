require_relative 'box/test-support'

module ::Skylab::MetaHell::TestSupport::Formal::Box

  describe "#{ MetaHell::Formal::Box } acts like a strict, #{
    }context-aware, ordered hash" do

    extend Box_TestSupport

    context "when it comes to visiting (enumerating / iteration), #{
      }honeybadger" do

      subject -> do
        box = new_modified_box
        box.add :one, :One
        box.add :two, :Two
        box
      end

      it "don't care, you want keys in your each?" do
        ks, vs = [], []
        subject.each do |k, v|
          ks << k ; vs << v
        end
        ks.should eql( [:one, :two] )
        vs.should eql( [:One, :Two] )
      end

      it "don't care, you want no keys in your each? (DIFFERENT than hash)" do
        vs = []
        subject.each do |v|
          vs << v
        end
        vs.should eql( [:One, :Two] )
      end

      it "you want map.to_a? you DON'T get keys " do
        x = subject.map.to_a
        x.should eql( [:One, :Two] )
      end

      it "if you do map{ |k, v| .. }.to_a then you COULD get keys" do
        x = subject.map do |k, v|
          "(#{ k.inspect }#{ v.inspect })"
        end.to_a
        x.join( ';' ).should eql( '(:one:One);(:two:Two)' )
      end

      it "if you do map { |v| .. }.to_a then you DON'T get keys" do
        x = subject.map do |v|
          v.to_s.reverse
        end.to_a
        x.should eql( ['enO', 'owT'] )
      end
    end

    context "honeybadger does advanced tricks" do

      subject -> do
        box = new_modified_box
        box.add :one, :One
        box.add :three, :Three
        box.add :five, :Five
        box
      end

      it "this is kind of weird: - arity IS an argument" do
        x1 = subject.select do |x|
          [:One, :Five].include? x
        end
        x2 = subject.select do |k, v|
          [:One, :Five].include? v
        end
        x1.length.should eql( 2 )
        x2.length.should eql( 2 )
        x1.first.should be_kind_of(::Symbol)
        x2.first.should be_kind_of(::Array)
      end
    end

    context "why did you make a method called `defectch`" do

      subject -> do
        box = new_modified_box
        box.add :one, :One
        box.add :three, :Three
        box.add :five, :Five
        box
      end

      it "when you defectch with (k, v) you get (k, v) back" do
        x = subject.defectch -> k, v do
          k == :three
        end
        x.should eql( [:three, :Three] )
        x.should be_kind_of(::Array)
      end

      it "when you defectch with (x) you get (y) back" do
        x = subject.defectch -> v do
          v == :Five
        end
        x.should eql( :Five )
      end

      it "can be used like a complicated fetch" do
        k1, v1 = subject.defectch -> k, v { :three == k }, -> { fail 'no' }
        k1.should eql( :three )
        v1.should eql( :Three )
        v2 = subject.defectch -> v { :NotThere == v }, -> { :alternate }
        v2.should eql( :alternate )
        begin
          subject.defectch -> x { false }
        rescue ::KeyError => e
        end
        e.to_s.should match( /value not found matching <#Proc.*box_spec/ ) # EEK
      end
    end
  end
end
