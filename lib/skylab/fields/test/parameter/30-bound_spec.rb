require_relative 'test-support'

describe "[hl] parameter - bound" do

  # (no Q-uickie because `before` blocks are used!)

  extend ::Skylab::Headless::TestSupport::Parameter

  def self.bound_with &b
    with do
      include ::Skylab::Headless::Parameter::Bound::InstanceMethods
      instance_exec(&b)
    end
  end

  context "lets you do questionable parameter reflection and manipulation" do

    bound_with do
      param :age, dsl: [:value, :reader]
      param :pet, dsl: [:list, :reader]
      param :hobby, accessor: true
    end

    frame do
      before :each do
        object.age 'fifty one'
        object.hobby = 'spelunk-fishing'
        object.pet 'goldfish'
        object.pet 'llama'
      end

      it "like iterate over each value in a flat, indifferent manner" do
        names = [] ; values = [] ; labels = []
        object.bound_parameters.each do |p|
          names.push p.normalized_parameter_name
          values.push p.value
          labels.push p.label
        end
        names.should eql([:age, :pet, :pet, :hobby])
        values.should eql(['fifty one', 'goldfish', 'llama', 'spelunk-fishing'])
        labels.join(' ').should eql("age pet[0] pet[1] hobby")
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

  context 'where clauses!' do
    bound_with do
      meta_param :this_one, boolean: true, accessor: true
      param :noun, dsl: [:list, :reader], enum: [:run, :walk], this_one: 1
      param :path, accessor: true, pathname: true, this_one: true
      param :herkemer, accessor: true, this_one: false
      param :derkemer, reader: true
    end

    frame do
      before :each do
        object.noun :walk, :walk, :run
        object.path = 'pathos'
        object.herkemer = 'the herkemer'
      end

      it '"object.bound_parameters reduce { |p| p.this_one? }" works!' do
        emit_lines.should be_empty
        object.noun.should eql([:walk, :walk, :run])
        object.path.should be_kind_of(::Pathname)
        object.path.to_s.should eql('pathos')
        bp = object.bound_parameters.reduce_by do | bp_ |
          bp_.this_one?
        end
        (bp = bp.to_a).length.should eql(4)
        bp.map{ |o| o.value.to_s }.should eql(%w(walk walk run pathos))
      end

      it '"object.bound_parameters reduce (with hash)' do
        bp = object.bound_parameters.reduce_by this_one: true
        (bp = bp.to_a).length.should eql(1) # contrast to above. do you know why
        bp.first.value.to_s.should eql('pathos')
      end

      it '"object.bound_parameters.at(:fee, :bar)" works!' do
        d, h = object.bound_parameters.at(:derkemer, :herkemer).to_a
        d.normalized_parameter_name.should eql(:derkemer)
        d.value.should be_nil
        h.normalized_parameter_name.should eql(:herkemer)
        h.value.should eql('the herkemer')
      end

      it '"object.beund_parameters[:nerk]" works!' do
        bp = object.bound_parameters[:noun]
        bp.value.should eql([:walk, :walk, :run])
      end
    end
  end
end
