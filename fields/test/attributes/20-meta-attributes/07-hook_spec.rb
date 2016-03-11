require_relative '../../test-support'

module Skylab::Fields::TestSupport

  if false
  context 'with a `hook` modifier' do

    with do
      param :on_error, :hook
    end

    frame do

      it "`object.on_foo { .. }` acts as a writer" do

        o = object_
        o.on_error { :x }
        force_read_( :error, o ).call.should eql :x
      end

      it "but out of the box there's no reader" do

        o = object_
        o.on_error { :x }
        o.respond_to?( :handle_error ).should eql false
      end

      it "also, we protect against misuse" do

        object = object_
        begin
          object.on_error
        rescue ::ArgumentError => e
        end
        e.message.should eql '[past-proofing]'
      end
    end
  end

  context "with a `hook` modifier with a `reader` modifier" do

    with do
      param :on_error, :hook, :reader
    end

    it "is useful if the client is to behave like an argument struct" do

      object = object_
      canary = :red
      object.on_error { canary = :blue }
      canary.should eql(:red)
      object.handle_error.call
      canary.should eql(:blue)
    end
  end
  end
end
