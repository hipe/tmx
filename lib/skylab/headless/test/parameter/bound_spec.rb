require_relative 'test-support'

describe Skylab::Headless::Parameter::Bound do
  extend ::Skylab::Headless::Parameter::TestSupport
  context "lets you do questionable parameter reflection and manipulation" do
    defn do
      include ::Skylab::Headless::Parameter::Bound::InstanceMethods
      param :age, dsl: [:value, :reader]
      param :pet, dsl: [:list, :reader]
      param :hobby, accessor: true
    protected
      def formal_parameters ; self.class.parameters end
    end
    frame do
      before(:each) do
        object.age 'fifty one'
        object.hobby = 'spelunk-fishing'
        object.pet 'goldfish'
        object.pet 'llama'
      end
      it "like iterate over each value in a flat, indifferent manner" do
        names = [] ; values = [] ; labels = []
        object.bound_parameters.each do |p|
          names.push p.name
          values.push p.value
          labels.push p.label
        end
        names.should eql([:age, :pet, :pet, :hobby])
        values.should eql(['fifty one', 'goldfish', 'llama', 'spelunk-fishing'])
        labels.join(' ').should eql(":age :pet[0] :pet[1] :hobby")
      end
      it "search through all values and change values procedurally" do
        object.bound_parameters.each do |p|
          if /fish/ =~ p.value
            p.value = p.value.gsub(/fish/, 'POTATO')
          end
        end
        o = object.instance_variable_get('@pet')
        o.should be_kind_of(::Array)
        o.join.should eql('goldPOTATOllama')
        object.hobby.should eql('spelunk-POTATOing')
      end
    end
  end
end
