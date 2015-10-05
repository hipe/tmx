require_relative '../test-support'

module Skylab::Basic::TestSupport

  describe "[ba] string - succ" do

    extend TS_
    use :string

    it "minimal" do
      p = subject
      p[].should eql '1'
      p[].should eql '2'
    end

    it "`beginning_number` (still no better than builtin `succ`)" do
      p = subject :beginning_number, 8
      p[].should eql '8'
      p[].should eql '9'
      p[].should eql '10'
    end

    it "`beginning_width`" do
      p = subject :beginning_number, 8, :beginning_width, 2
      p[].should eql '08'
      p[].should eql '09'
      p[].should eql '010'
      p[].should eql '011'
    end

    it "`template`" do
      p = subject :beginning_number, 3, :template, 'x{{ ID }}'
      p[].should eql 'x3'
      p[].should eql 'x4'
    end

    it "`first_item_does_not_use_number`" do
      p = subject :first_item_does_not_use_number,
        :template, 'x{{ ID }}'
      p[].should eql 'x'
      p[].should eql 'x2'
      p[].should eql 'x3'
    end

    it "what you write in the template alters the syntax" do
      p = subject :template, '{{ foo }}-hi-{{ ID }}',
        :foo, 'x'

      p[].should eql 'x-hi-1'
      p[].should eql 'x-hi-2'
    end

    it "so it matters where the template keyword goes" do
      _rx = /template variable `hi` not found\. did you mean x\?/

      -> do
        subject :template, '{{ x }}', :hi
      end.should raise_error ::ArgumentError, _rx
    end

    it "omg templates with hacked conditionals" do

      p = subject(

        :beginning_width, 2,
        :first_item_does_not_use_number,

        :template, '{{ head }}{{ separator if ID }}{{ ID }}{{ tail }}',

        :head, 'hi',
        :tail, '.foo',
        :separator, '-' )  # DASH_

      p[].should eql 'hi.foo'
      p[].should eql 'hi-02.foo'
      p[].should eql 'hi-03.foo'

    end

    def subject * x_a
      subject_module_::Succ__.call_via_iambic x_a
    end
  end
end
