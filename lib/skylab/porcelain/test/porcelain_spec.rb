# do not touch this file while it is green -- this file is under active
# study, and cross-ticketed at [#bs-008] and [#111]

require File.expand_path('../test-support', __FILE__)
require File.expand_path('../../all', __FILE__)


module Skylab::Porcelain::TestSupport
  Porcelain = ::Skylab::Porcelain

  describe "The #{Porcelain} module" do
    include Porcelain::Styles # unstylize
    let(:debug_ui) { }
    let(:_stderr) { StringIO.new }
    let(:stderr) { _stderr.string }
    let(:instance) do
      klass.new do |o|
        o.on_all { |e| _stderr.puts unstylize(e) ; debug_ui and $stderr.puts("DBG-->#{e}<--") }
      end
    end
    describe "extended by a class allows that" do
      let(:klass) do
        Class.new.class_eval do
          extend Porcelain
          def foo ; end
          def bar ; end
          def self.to_s ; "WhoHah" end
        private
          def baz ; end
          self
        end
      end
      let(:child_class) do
        Class.new(klass).class_eval do
          def she_bang ; end
          def self.to_s ; "BooHah" end
          self
        end
      end
      it "the class's public instance methods will make up its public interface / api (actions)" do
        klass.actions.map(&:action_name).should eql([:help, :foo, :bar])
      end
      it "the class can access the action property by name (which is a dashed version of the method name)" do
        child_class.actions[:'she-bang'].action_name.should eql(:'she-bang')
      end
      it "although it is an enumerator, the actions knob returns a consistent object per action" do
        oid = child_class.actions[:'she-bang'].object_id
        child_class.actions[:'she-bang'].object_id.should eql(oid)
        child_class.actions.detect{ |a| a.action_name == :'she-bang' }.object_id.should eql(oid)
      end
      it "any child class of the class will also have this property and inherit the list of actions from its parent" do
        child_class.actions.map(&:action_name).should eql([:help, :foo, :bar, :'she-bang'])
      end
      context "a simple ancestor chain of 'parent' module and child class" do
        let(:parent)    {         Module.new.module_eval         { extend Porcelain ; def act_m ; end ; self } }
        let(:child)     { o=self ; Class.new.class_eval          { extend Porcelain ; def act_c ; end ; include o.parent ; self } }
        it "child gets parent actions, order is respected (but it's a smell to depend on this)" do
          child.actions.map(&:action_name).should eql([:help, :'act-c', :'act-m'])
        end
      end
      describe "all modules in the ancestor chain" do
        let(:module_a)  {          Module.new.module_eval        { extend Porcelain ; def act_a ; end ; self } }
        let(:module_b)  { o=self ; Module.new.module_eval        { extend Porcelain ; def act_b ; end ; include o.module_a ; self } }
        let(:module_c)  {          Module.new.module_eval        { extend Porcelain ; def act_c ; end ; self } }
        let(:module_d)  {          Module.new.module_eval        { extend Porcelain ; def act_d ; end ; self } }
        let(:class_e)   { o=self ; Class.new.class_eval          { extend Porcelain ; def act_e ; end ; include o.module_b, o.module_c ; self } }
        let(:class_f)   { o=self ; Class.new(class_e).class_eval { extend Porcelain ; def act_f ; end ; include o.module_d ; self } }
        it "get their actions inherited, in a particular order: officious, parent class, [..], my actions, modules included after" do
          ('a'..'f').map { |l| "#{(respond_to?("module_#{l}") ? :module : :class)}_#{l}" }.
                     each { |n| send(n).singleton_class.send(:define_method, :to_s) { n } }
          class_f.actions.map{ |a| a.action_name.to_s }.should eql(%w(help act-e act-b act-a act-c act-f act-d))
        end
      end
    end
    describe "DSL" do
      let(:klass) do
        Class.new.class_eval do
          extend Porcelain
          option_syntax { }
          argument_syntax '<foo>'
          def bar foo ; end
          self
        end
      end
      context "allows you to associate a description" do
        let(:klass) do
          ohai = self
          Class.new.class_eval do
            extend Porcelain
            module_eval(& ohai.desco)
            def ferp_derp one ; end
            self
          end
        end
        context "but when you don't (but note you need something else)" do
          let(:desco) { ->(_){  argument_syntax '<one>' } }
          it "the description lines will be nil" do
            klass.actions[:ferp_derp].description_lines.should eql(nil)
          end
        end
        context "with one line" do
          let(:desco) { ->(_){
            desc "ferpie"
          } }
          it "gives the one description line" do
            klass.actions[:ferp_derp].description_lines.should eql(['ferpie'])
          end
        end
        context "with two lines" do
          let(:desco) { ->(_){  desc "ferpie" ; desc "lerpie" } }
          it "gives the two description lines" do
            klass.actions[:ferp_derp].description_lines.should eql(%w(ferpie lerpie))
          end
        end
      end
      it "is used for defining option and argument syntax" do
        klass.actions[:bar].argument_syntax.to_str.should eql('<foo>')
      end
      describe 'provides an argument syntax in which' do
        it "you can inspect the number of parameters (like nonternimal symbols)" do
          klass.actions[:bar].argument_syntax.count.should eql(1)
        end
        def _ str
          __(str).first
        end
        def __ str
           Porcelain::ArgumentSyntax.parse_syntax(str)
        end
        describe "a required parameter (a [1..1] ranged parameter)" do
          let(:parameter) {  _ '<foo>' }
          it("knows it is required") { parameter.required?.should eql(true) }
          it("unparses correctly") { parameter.to_str.should eql('<foo>') }
        end
        describe "an optional parameter (a [0..1] ranged parameter)" do
          let(:parameter) { _ '[<foo>]' }
          it("knows it is not required") { parameter.required?.should eql(false) }
          it("unparses like so") { parameter.to_str.should eql('[<foo>]') }
        end
        describe "a [1..] ranged parameter" do
          let(:parameter) { _ '<foo>[<foo>[...]]' }
          it("knows it is required") { parameter.required?.should eql(true) }
          it("unparses like so") { parameter.to_str.should eql('<foo> [<foo>[...]]') }
          context do
            let(:parameter) { _ '<foo> [..]' }
            it("can also be notated this way") { parameter.required?.should eql(true) }
            it("but unparses the same as above") { parameter.to_str.should eql('<foo> [<foo>[...]]') }
          end
        end
        describe "a [0..] ranged parameter" do
          let(:parameter) { _ '[<foo> [<foo> [...]]]' }
          it("knows it is not required") { parameter.required?.should eql(false) }
          it("unparses like so") { parameter.to_str.should eql('[<foo> [<foo>[...]]]') }
          context do
            let(:parameter) { _ '[<foo> [..]]' }
            it("can also be notated in this way") { parameter.required?.should eql(false) }
            it("but unparses the same as above") { parameter.to_str.should eql('[<foo> [<foo>[...]]]') }
          end
        end
        describe "glob" do
          it "can be one optional parameter at the end" do
            __('<a> [<b> [<b> [..]]]').count.should eql(2)
          end
          it "can be one required parameter at the end" do
            __('<a> <b> [<b> [..]]').count.should eql(2)
          end
          it "can be the only parameter, and required" do
            __('<a> [<a> [..]]').count.should eql(1)
          end
          it "can be the only parameter, and optional" do
            __('[<a> [<a> [..]]]').count.should eql(1)
          end
          it "cannot occur more than once" do
            lambda{ __('<a> [<b> [..]] [<c> [..]]') }.should raise_exception(/cannot .+ more than once/i)
            lambda{ __('[<b> [..]] [<c> [..]] <a>') }.should raise_exception(/cannot .+ more than once/i)
            lambda{ __('<a> [<b> [..]] [<c> [..]] <d>') }.should raise_exception(/cannot .+ more than once/i)
          end
          it "cannot occur at the beginning (for now)" do
            lambda{ __('<a> [<a> [..]] <b>') }.should raise_exception(/cannot .+ at the beginning/i)
          end
          it "cannot occur in the middle" do
            lambda{ __('<a> [<b> [..]] <c>') }.should raise_exception(/cannot .+ in the middle/i)
          end
        end
        describe "optional" do
          it "can occur more than once at the end" do
            __('<a> [<b>] [<c>]').count.should eql(3)
          end
          it "cannot occur at the beginning" do
            lambda{ __('[<a>] <b>') }.should raise_exception(/optionals cannot occur at the beginning/i)
          end
          it "cannot occur in the middle" do
            lambda{ __('<a> [<b>] <c>') }.should raise_exception(/optionals cannot occur in the middle/i)
          end
          describe "can occur in conjunction with globs, provided the above rules are followed" do
            it "with a trailing optional glob" do
              __('<a> [<b>] [<c>] [<d> [<d> [..]]]').count.should eql(4)
            end
            it "but not with a trailing required glob, e.g." do
              lambda{ __('<a> [<b>] [<c>] <d> [<d> [..]]') }.should raise_exception(/optionals cannot occur in the middle/i)
            end
          end
        end # optional
        describe "a syntax for arguments of" do
          let(:knob) { lambda { |k| k.on_all { |e| _stderr.puts e } } }
          describe "zero-length" do
            let(:syntax) { Porcelain::ArgumentSyntax.parse_syntax('') }
            it "against the zero-length args emits no errors and returns true" do
              syntax.parse_arguments(argv = [], &knob).should eql(true)
              stderr.should eql('')
              argv.should eql([])
            end
            it "against a nonzero-length args emits an error and returns false" do
              syntax.parse_arguments(argv = %w(alpha beta), &knob).should eql(false)
              stderr.should match(/unexpected argument/i)
              argv.should eql(%w(alpha beta))
            end
          end
          describe "zero-or-one-length" do
            let(:syntax) { Porcelain::ArgumentSyntax.parse_syntax('[<foo>]') }
            it "against the zero-length args emits no errors and returns true" do
              syntax.parse_arguments(argv = [], &knob).should eql(true)
              stderr.should eql('')
              argv.should eql([])
            end
            it "against one-length args emits no errors and returns true" do
              syntax.parse_arguments(argv = ['first'], &knob).should eql(true)
              stderr.should eql('')
              argv.should eql(['first'])
            end
          end
          describe "zero-to-many length" do
            let(:syntax) { Porcelain::ArgumentSyntax.parse_syntax('[<foo> [..]]') }
            it "against the zero-length args emits no errors and returns true" do
              syntax.parse_arguments(argv = [], &knob).should eql(true)
              stderr.should eql('')
              argv.should eql([])
            end
            it "against one-length args emits no errors and returns true" do
              syntax.parse_arguments(argv = ['first'], &knob).should eql(true)
              stderr.should eql('')
              argv.should eql(['first'])
            end
            it "against many-length args emits no errors and returns true" do
              syntax.parse_arguments(argv = ['first', 'second'], &knob).should eql(true)
              stderr.should eql('')
              argv.should eql(['first', 'second'])
            end
          end
          describe "a required, an optional, then a glob" do
            let(:syntax) { Porcelain::ArgumentSyntax.parse_syntax('<foo> [<bar>] [<baz> [..]]') }
            it "against the zero-length args emits an error and returns false" do
              syntax.parse_arguments(argv = [], &knob).should eql(false)
              stderr.should match(/expecting.+<foo>/)
              argv.should eql([])
            end
            it "against one is ok" do
              syntax.parse_arguments(argv = ['one'], &knob).should eql(true)
              stderr.should eql('')
              argv.should eql(['one'])
            end
            it "againt five is ok" do
              syntax.parse_arguments(argv = %w(one two three four five), &knob).should eql(true)
              stderr.should eql('')
              argv.should eql(%w(one two three four five))
            end
          end # n length
        end # of
      end # ArgumentSyntax
    end # DSL
    describe "invocation happens with a call to invoke() (pass it ARGV) that" do
      let(:expecting_foo_bar) { /expecting \{(?:help\|)?foo\|bar\}/i }
      let(:klass) do
        Class.new.class_eval do
          extend Porcelain
          porcelain do
            invocation_name 'yourapp'
          end
          def foo ; end
          def bar ; end
        private
          def baz ; end
          self
        end
      end
      it "with empty argv it complains, lists available actions and invites to more help" do
        instance.invoke []
        stderr.should match(expecting_foo_bar)
        stderr.should match(/try yourapp -h for help/i)
      end
      it "with a bad action name it complains, lists available actions and invites to more help" do
        instance.invoke ['derpis']
        stderr.should match(/invalid action: derpis/i)
        stderr.should match(expecting_foo_bar)
      end
      it "with -h or --help as the first argument, you get help (listing of avaiable commands)" do
        instance.invoke ['-h']
        stderr.should match(/usage: yourapp \{(?:help\|)?foo\|bar\}/i)
        stderr.should match(/for help on a particular subcommand/i)
      end
      it "with -h (or help) followed by an action name, you get action-specific help" do
        instance.invoke ['-h', 'foo']
        stderr.should match(/usage: yourapp foo/i)
      end
      describe "does fuzzy matching on the action name" do
        let(:klass) do
          Class.new.class_eval do
            extend Porcelain
            def pliny ; end
            def plone ; end
            self
          end
        end
        it "by default" do
          instance.invoke %w(pl)
          stderr.should match(/ambiguous action[ ":]+pl/i)
          stderr.should match(/did you mean pliny or plone/i)
        end
        describe "but by using the config" do
          let(:klass) do
            Class.new.class_eval do
              extend Porcelain
              porcelain { fuzzy_match false }
              def pliny ; end
              def plone ; end
              self
            end
          end
          it "it can be turned off" do
            instance.invoke %w(pl)
            stderr.should match(/invalid action[ :"]+pl/i)
            stderr.should match(/expecting.+pliny\|plone/i)
          end
        end
      end
    end
    describe "when invoking an actions with no syntaxes defined (just public methods)" do
      let(:klass) do
        Class.new.class_eval do
          extend Porcelain
        inactionable
          porcelain.invocation_name 'yourapp'
          attr_reader :argv ; private :argv
          def initialize &b
            @argv = @touched = nil
            porcelain_init(&b)
          end
        public
          def takes_no_arguments
            @touched = true
          end
        private
          attr_reader :touched
          self
        end
      end
      it "if no args are given it will enumerate the available actions (methods)" do
        instance.invoke []
        stderr = self.stderr
        stderr.should match(/expecting.+takes-no-arguments/i)
      end
      describe "with one such action whose methods take no arguments" do
        it "if you pass it no arguments, it is called" do
          instance.invoke %w(takes-no-arguments)
          instance.send(:touched).should eql(true)
          stderr.should eql('')
        end
        it "if you pass it some arguments, it reports a syntax error and shows usage and invites for help" do
          i = instance
          i.invoke(%w(takes-no-arguments first-arg)).should eql(nil)
          s = stderr.split("\n")
          s.shift.should match(/unexpected argument[: ]+"first-arg"/i)
          s.shift.should match(/usage: yourapp takes-no-arguments/i)
          s.shift.should match(/try .* for help/i)
          s.size.should eql(0)
        end
      end
    end
    describe "provides rendering" do
      let(:definition_block) do
        lambda do |_|
          option_syntax do |ctx|
            on('-a', '--apple', "an apple")
            on('-p', '--pear[=foo]',  "a pear")
            on('--bananna=<type>', "a bananna")
          end
          argument_syntax '<foo> [<bar>]'
          def whatever_is_clever foo, bar=nil; end
        end
      end
      let(:action) do
        o = self
        Porcelain::Action.new do
          module_eval(& o.definition_block)
        end
      end
      let(:klass) do
        this = self
        Class.new.class_eval do
          extend Porcelain
          porcelain.invocation_name 'yourapp'
          class_eval(&this.definition_block)
          self
        end
      end
      describe "of syntax that provides more detail than optparse:" do
        subject { action.syntax }
        specify { should eql('whatever-is-clever [-a] [-p[=foo]] [--bananna=<type>] <foo> [<bar>]') }
      end
      describe "of help screens" do
        it "will use optparse's rendering of help screen for the options" do
          instance.invoke(%w(whatever-is-clever -h))
          help_screen = stderr
          help_screen.should match(/usage: yourapp whatever-is-clever/i)
          help_screen.should match(/-a, --apple +an apple/)
        end
      end
    end # provides rendering
    context "allows you to specify default actions (actually argvs), for e.g.:" do
      context 'with an app with actions "foo" and "bar"' do
        let(:klass) do
          o = self
          Class.new.class_eval do
            extend ::Skylab::Porcelain
            class_eval(& o.body)
            def foo
              runtime.emit(:info, "I am foo.")
            end
            def bar
              runtime.emit(:info, "I am bar.")
            end
            self
          end
        end
        let(:subject) do
          instance.invoke argv
          stderr.match(/\A[^\n]+/)[0]
        end
        context "that does not specify a default argv" do
          let(:body) { ->(_) { } }
          context "against an argv with no arguments" do
            let(:argv) { [] }
            context "you get response whose first line" do
              specify { should match(/expecting .*foo.*bar/i) }
            end
          end
        end
        context "that specifies a default of :foo" do
          let(:body) { ->(_) { porcelain { default :foo } } }
          context 'against an argv with no arguments' do
            let(:argv) { [] }
            context "it will run foo" do
              specify { should match(/^I am foo\.$/) }
            end
          end
          context "against an argv with [bar]" do
            let(:argv) { ['bar'] }
            context "it does this" do
              specify { should match(/^I am bar\.$/) }
            end
          end
          context "against an argv with [baz]" do
            let(:argv) { ['baz'] }
            context "it does this" do
              specify { should match(/Invalid action\: baz/i) }
            end
          end
        end
        context "that specifies a multi-argument default" do
          let(:body) { ->(_) { porcelain { default %w(foo -x) } } }
          context "it works" do
            let(:argv) { [] }
            specify { should match(/unexpected argument.+-x/i) }
          end
        end
      end
    end
    context "With regards to Namespaces.." do
      context "Porcelain itself" do
        subject { Porcelain }
        it { should respond_to(:namespaces) }
      end
      context "the result of a call to #namespaces" do
        subject { Porcelain.namespaces }
        it { should be_kind_of(Array) }
      end
      context "if you try to use both an external class and an inline namespace definition"
      context "if you try to use neither external class nor internal namespace defnition"

      let(:klass_with_inline_namespace) do
        Class.new.module_eval do
          extend Porcelain
          porcelain.invocation_name = 'wahoo'
          namespace :'more' do
            def tingle
              runtime.emit(:info, "yes sure tingle inline")
              :yes_tingle
            end
          end
          def duckle ; end
          self
        end
      end
      let(:klass_for_namespace) do
        Class.new.class_eval do
          extend Porcelain
          def tingle
            runtime.emit(:info, "yes sure tingle external")
            :yes_tingle
          end
          self
        end
      end
      let(:klass_with_external_namespace) do
        o = self
        Class.new.class_eval do
          extend Porcelain
          porcelain.invocation_name = 'wahoo'
          namespace :'more', o.klass_for_namespace
          def duckle ; end
          self
        end
      end
      context "(sanity check regression)" do
        it "namespace class action names look ok" do
          klass_for_namespace.actions.map(&:action_name).should eql([:help, :tingle])
        end
        it "class with inline namespace action names look ok" do
          klass_with_inline_namespace.actions.map(&:action_name).should eql([:help, :more, :duckle])
        end
        it "class with external namespace action names look ok" do
          klass_with_external_namespace.actions.map(&:action_name).should eql([:help, :more, :duckle])
        end
      end
      context "(class with inline namespace regression)" do
        it "does" do
          ns = klass_with_inline_namespace.actions[:more]
          ns.actions_provider.actions.map(&:action_name).should(
            eql([:help, :tingle])
          )
        end
      end
      [ { :name => 'an external class',
          :var  => :klass_with_external_namespace
        },
        { :name => 'an inline namespace definition',
          :var  => :klass_with_inline_namespace
        }
      ].each do |o|

        name, var = %w(name var).map { |k| o[k.intern] }

        context "when you have <<#{name}>>.." do

          let(:klass) { send(var) }

          context "stdout response" do

            before { @result = instance.invoke argv }

            subject { stderr.split("\n").first }

            context "[]" do
              let(:argv) { [] }
              specify { should match(/expecting.*more.*duckle/i) }
            end
            context "-h" do
              let(:argv) { %w(-h) }
              specify { should match(/^usage: wahoo \{ *more *\| *duckle *\}/) }
            end
            context "foo" do
              let(:argv) { %w(foo) }
              specify { should match(/invalid action: foo/i) }
            end
            context "more" do
              let(:argv) { %w(more) }
              specify { should match(/expecting.*action/i) }
            end
            context "more -h" do
              let(:argv) { %w(more -h) }
              specify do
                should match(/^usage.*wahoo.*more.*tingle.*opts.*args/i)
              end
            end
            context "more wang" do
              let(:argv) { %w(more wang) }
              specify { should match(/invalid action: wang/i) }
            end
            context "more tingle foo" do
              let(:argv) { %w(more tingle foo) }
              specify { should match(/unexpected argument.*foo/i) }
            end
            context "more tingle -h" do
              let(:argv) { %w(more tingle -h) }
              specify { should match(/^usage: wahoo more tingle/i) }
            end
            context "more tingle" do
              let(:argv) {%w(more tingle)}
              specify { should match(/^yes sure tingle (?:inline|external)/) }
              context "result" do
                subject { @result }
                specify { should eql(:yes_tingle) }
              end
            end
          end
        end
      end
    end
    context "when you don't explicitly tell it the args syntax" do
      let(:klass) do
        o = self
        Class.new.class_eval do
          extend ::Skylab::Porcelain
          porcelain.invocation_name = "doipus"
          module_eval(& o.body)
          self
        end
      end
      let(:subject) do
        @return = instance.invoke argv
        stderr.match(/\A[^\n]+/)[0]
      end
      context "basic one arg def" do
        let(:body) do
          lambda do |_|
            def foo first
              runtime.emit(:info, "i am foo with: #{first}.")
              :ok_foo
            end
          end
        end
        context "foo -h" do
          let(:argv) { %w(foo -h) }
          specify { should match(/usage: doipus foo <arg1>/i) }
        end
        context "foo" do
          let(:argv) { %w(foo) }
          specify { should match(/expecting.*arg1/i) }
        end
        context "foo bizzie" do
          let(:argv) { %w(foo bizzie) }
          specify { should match(/i am foo with: bizzie\./i) }
        end
        context "foo biz baz" do
          let(:argv) { %w(foo biz baz) }
          specify { should match(/unexpected argument.*baz/i) }
        end
      end
      context "trailing optional" do
        let(:body) do
          lambda do |_|
            def foo first, second=nil
              runtime.emit(:info, "i am foo with: #{first}, #{second}.")
              :ok_foo
            end
          end
        end
        context "foo -h" do
          let(:argv) { %w(foo -h) }
          specify { should be_include('foo <arg1> [<arg> [<arg>[...]]]') }
        end
        context "foo biz baz boz" do
          let(:argv) { %w(foo biz baz boz) }
          it "will still throw an argument error" do
            lambda { instance.invoke(argv) }.
              should raise_exception(ArgumentError, /wrong number of arguments \(3 for 2\)/)
          end
        end
      end
    end
  end
end

