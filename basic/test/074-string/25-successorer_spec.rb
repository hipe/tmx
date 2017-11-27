require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - succ" do

    TS_[ self ]
    use :string

    it "minimal" do
      p = subject
      expect( p[] ).to eql '1'
      expect( p[] ).to eql '2'
    end

    it "`beginning_number` (still no better than builtin `succ`)" do
      p = subject :beginning_number, 8
      expect( p[] ).to eql '8'
      expect( p[] ).to eql '9'
      expect( p[] ).to eql '10'
    end

    it "`beginning_width`" do
      p = subject :beginning_number, 8, :beginning_width, 2
      expect( p[] ).to eql '08'
      expect( p[] ).to eql '09'
      expect( p[] ).to eql '010'
      expect( p[] ).to eql '011'
    end

    it "`template`" do
      p = subject :beginning_number, 3, :template, 'x{{ ID }}'
      expect( p[] ).to eql 'x3'
      expect( p[] ).to eql 'x4'
    end

    it "`first_item_does_not_use_number`" do  # #spot-1
      p = subject :first_item_does_not_use_number,
        :template, 'x{{ ID }}'
      expect( p[] ).to eql 'x'
      expect( p[] ).to eql 'x2'
      expect( p[] ).to eql 'x3'
    end

    it "what you write in the template alters the syntax" do
      p = subject :template, '{{ foo }}-hi-{{ ID }}',
        :foo, 'x'

      expect( p[] ).to eql 'x-hi-1'
      expect( p[] ).to eql 'x-hi-2'
    end

    it "so it matters where the template keyword goes" do
      _rx = /template variable `hi` not found\. did you mean x\?/

      expect( -> do
        subject :template, '{{ x }}', :hi
      end ).to raise_error ::ArgumentError, _rx
    end

    it "omg templates with hacked conditionals" do

      p = subject(

        :beginning_width, 2,
        :first_item_does_not_use_number,

        :template, '{{ head }}{{ separator if ID }}{{ ID }}{{ tail }}',

        :head, 'hi',
        :tail, '.foo',
        :separator, '-' )  # DASH_

      expect( p[] ).to eql 'hi.foo'
      expect( p[] ).to eql 'hi-02.foo'
      expect( p[] ).to eql 'hi-03.foo'

    end

    def subject * x_a
      subject_module_::Successorer.call_via_iambic x_a
    end
  end
end
