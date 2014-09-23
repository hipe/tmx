require_relative 'test-support'

module Skylab::TanMan::TestSupport::Models::Meaning

  describe "[tm] Models::Meaning core" do

    extend TS_

    it "add - in between" do
      s = " # cutie : pattootey\n  # fazinkle: doo-dinkle\n"
      insert_foo_bar_into s
      s.should eql " # cutie : pattootey\n  # fazinkle: doo-dinkle\n  #      foo: bar\n"
      expect_succeeded
    end

    it "add - before" do
      s = " /* winterly : wanterly \n bliff blaff */ "
      insert_foo_bar_into s
      s.should eql " /* winterly : wanterly \n         foo : bar\n bliff blaff */ "
      expect_succeeded
    end

    it "add - after" do
      s = "  /* dolan : is \n a : duck \n */ "
      insert_foo_bar_into s
      s.should eql "  /* dolan : is \n a : duck \nfoo : bar\n */ "
      expect_succeeded
    end

    it "add to string with one space" do
      s = ' '
      insert_foo_bar_into s
      s.should eql "  foo : bar\n"
      expect_succeeded
    end

    it "add will not clobber" do
      s = ' foo : x '
      insert_foo_bar_into s
      expect :not_OK, :name_collision,
        "cannot set 'foo' to \"bar\", it is already set to \"x \""
      expect_failed
    end

    def insert_foo_bar_into s
      call_API :meaning, :add, :input_string, s, :output_string, s, :name, 'foo', :value, 'bar'
    end

    it "list when input string has no parsable lines" do
      call_API :meaning, :ls, :input_string, "jibber\njabber"
      expect :OK, :number_of_items_found do |ev|
        ev.to_event.count.should be_zero
      end
      expect_succeeded
    end

    it "list when input string has parsable lines" do

      call_API :meaning, :ls, :input_string, " foo : fee \n fiffle: faffle"

      expect :OK, :item do |ev|
        ent = ev.flyweighted_entity
        ent.property_value( :name ).should eql 'foo'
        ent.property_value( :value ).should eql 'fee '
      end

      expect :OK, :item do |ev|
        ent = ev.flyweighted_entity
        ent.property_value( :name ).should eql 'fiffle'
        ent.property_value( :value ).should eql 'faffle'
      end

      expect :OK, :number_of_items_found do |ev|
        ev.to_event.count.should eql 2
      end

      expect_succeeded
    end

    it "add one before one - HERE HAVE A COMMA (this was hard) BUT IT IS MAGIC", wip: true do
                                  # client.parser.root = :node_stmt
      graph = client.parse_string <<-O.unindent
        digraph {
          barl [label=barl]
        }
      O

      stmt = graph.node_statements.first
      alist = stmt.attr_list.content
      alist.class.should eql( TanMan_::Models::DotFile::Sexps::AList ) # meh
      alist._prototype = graph.class.parse :a_list, 'a=b, c=d'
      alist.unparse.should eql( 'label=barl' )
      alist._prototype.unparse.should eql( 'a=b, c=d' )
      alist._insert_assignment! :fontname, 'Futura'
      alist.unparse.should eql('fontname=Futura, label=barl')
    end


    it "UPDATE ONE AND ADD ONE -- WHAT WILL HAPPEN!!?? - note order logic", wip: true do

      graph = client.parse_string <<-O.unindent
        digraph {
          barl [label=barl, fillcolor="too"]
        }
      O

      stmt = graph.node_statements.first
      alist = stmt.attr_list.content
      alist.unparse.should eql( 'label=barl, fillcolor="too"' )
      attrs = [['fontname', 'Futura'], ['fillcolor', '#11c11']]
      alist._update_attributes! attrs
      alist.unparse.should eql(
        'fontname=Futura, label=barl, fillcolor="#11c11"'  )
    end
  end
end
