require_relative '../test-support'

describe "[fi] P - bound" do

  extend Skylab::Fields::TestSupport
  use :parameter

  it "loads" do
    Skylab::Fields::Parameter::Bound
  end

  def self._with & edit_p

    with do

      define_method :bound_parameters,
        Skylab::Fields::Parameter::Bound::PARAMETERS_METHOD

      class_exec( & edit_p )
    end
  end

  context "lets you do questionable parameter reflection and manipulation" do

    _with do

      param :age, :DSL, :atom, :reader
      param :pet, :DSL, :list, :reader
      param :hobby, :accessor
    end

    frame do

      before :each do  # (is modified in one test, not in another)

        object = object_
        object.age 'fifty one'
        object.hobby = 'spelunk-fishing'
        object.pet 'goldfish'
        object.pet 'llama'
      end

      it "like iterate over names & values" do

        names = []
        values = []

        object_.bound_parameters.each do |p|
          names.push p.name.as_variegated_symbol
          values.push p.value
        end

        names.should eql [ :age, :pet, :hobby ]

        values.should eql(
          [ "fifty one", [ "goldfish", "llama" ], "spelunk-fishing" ] )
      end

      it "search through all values and change values procedurally" do

        object = object_

        _st = object.bound_parameters.to_value_stream.expand_by do | bnd |  # mentor

          if bnd.parameter.is_list
            bnd.to_stream
          else
            Skylab::Callback::Stream.via_item bnd
          end
        end

        rx = /fish/

        _st.each do | bnd |
          if rx =~ bnd.value
            bnd.value = bnd.value.gsub rx, 'POTATO'
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

    _with do

      meta_param :this_one, :boolean
      param :noun, :DSL, :list, :reader, :enum, [ :run, :walk ], :this_one
      param :path, :accessor, :this_one
      param :herkemer, :accessor
      param :derkemer, :reader
    end

    frame do

      it "`to_bound_item_stream`" do

        object = _read_only_object

        object.noun_array.should eql [ :walk, :walk, :run ]

        object.path.should eql 'pathos'

        a = object.bound_parameters.to_bound_item_stream.reduce_by do | bp |
          bp.parameter.this_one?
        end.to_a

        a.length.should eql 4

        a.map( & :value ).should eql [ :walk, :walk, :run, 'pathos' ]
      end

      it "`at`" do

        d, h = _read_only_bound_parameters.at :derkemer, :herkemer

        d.name_symbol.should eql :derkemer
        d.value.should be_nil
        h.name_symbol.should eql :herkemer
        h.value.should eql('the herkemer')
      end

      it "`fetch`" do

        _bp = _read_only_bound_parameters.fetch :noun

        _bp.value.should eql [ :walk, :walk, :run ]
      end

      dangerous_memoize_ :_read_only_bound_parameters do

        _read_only_object.bound_parameters
      end

      dangerous_memoize_ :_read_only_object do

        o = object_
        o.noun :walk
        o.noun :walk
        o.noun :run
        o.path = 'pathos'
        o.herkemer = 'the herkemer'
        o
      end
    end
  end
end
