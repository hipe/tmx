# do not touch this file while it is green -- this file is under active
# study, and cross-ticketed at [#bs-008] and [#111]

require File.expand_path('../test-support', __FILE__)
require_relative '../core'


module Skylab::Porcelain::TestSupport



  describe "[po] legacy" do
    extend Porcelain_TestSupport
    def _stderr  # wind this back to see an even messier version
      @_stderr ||= ::StringIO.new
    end

    let(:stderr) { _stderr.string }

    let :styled_stderr do
      unstyle_styled _stderr.string
    end

    let(:instance) do
      kls = klass
      if TestLib_::Method_is_defined_by_module[
          :listeners_digraph, kls.singleton_class ]
        # test both ways of event wiring..
        inst = kls.new do |o|
          # (tombstone of a great [#bm-008] vector)
          o.on_all do |e|
            _stderr.puts e.text  # might be styled
            do_debug and TestSupport::System.stderr.puts "(dbg:#{ e.text })"
            nil
          end
        end
      else
        if do_debug
          @_stderr ||= TestSupport::IO::Spy.standard.debug!
        end
        inst = kls.new nil, _stderr, _stderr
      end
      inst
    end
    context "(part 1 - inheritance) extended by a class allows that" do
      let(:klass) do
        Class.new.class_eval do
          Porcelain::Legacy::DSL[ self ]
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
        klass.actions.map(&:normalized_local_action_name).should eql([:help, :foo, :bar])
      end
      it "the class can access the action property by name (which is the method name)" do
        child_class.actions[:she_bang].normalized_local_action_name.should eql(:she_bang)
      end
      it "although it is an enumerator, the \"story\" returns a consistent object per action" do
        oid = child_class.actions[:she_bang].object_id
        child_class.actions[:she_bang].object_id.should eql(oid)
        child_class.actions.detect{ |a| a.normalized_local_action_name == :she_bang }.object_id.should eql(oid)
      end
      it "any child class of the class will also have this property and inherit the list of actions from its parent" do
        child_class.actions.map(&:normalized_local_action_name).should eql([:help, :foo, :bar, :she_bang])
      end
      context "a simple ancestor chain of 'parent' module and child class" do
        let(:parent)    {         Module.new.module_eval         { Porcelain::Legacy::DSL[ self ] ; def act_m ; end ; self } }
        let(:child)     { o=self ; Class.new.class_eval          { Porcelain::Legacy::DSL[ self ] ; def act_c ; end ; include o.parent ; self } }
        it "child gets parent actions, order is respected (but it's a smell to depend on this)" do
          child.actions.map(&:normalized_local_action_name).should eql([:help, :act_c, :act_m])
        end
      end
      context "all modules in the ancestor chain" do
        let(:module_a)  {          Module.new.module_eval        { Porcelain::Legacy::DSL[ self ] ; def act_a ; end ; self } }
        let(:module_b)  { o=self ; Module.new.module_eval        { Porcelain::Legacy::DSL[ self ] ; def act_b ; end ; include o.module_a ; self } }
        let(:module_c)  {          Module.new.module_eval        { Porcelain::Legacy::DSL[ self ] ; def act_c ; end ; self } }
        let(:module_d)  {          Module.new.module_eval        { Porcelain::Legacy::DSL[ self ] ; def act_d ; end ; self } }
        let(:class_e)   { o=self ; Class.new.class_eval          { Porcelain::Legacy::DSL[ self ] ; def act_e ; end ; include o.module_b, o.module_c ; self } }
        let(:class_f)   { o=self ; Class.new(class_e).class_eval { Porcelain::Legacy::DSL[ self ] ; def act_f ; end ; include o.module_d ; self } }
        it "get their actions inherited, in a particular order: officious, parent class, [..], my actions, modules included after" do
          ('a'..'f').map { |l| "#{(respond_to?("module_#{l}") ? :module : :class)}_#{l}" }.
                     each { |n| send(n).singleton_class.send(:define_method, :to_s) { n } }
          class_f.actions.map{ |a| a.slug }.should eql(%w(help act-e act-b act-a act-c act-f act-d))
        end
      end
    end
    context "(part 2 - desc and argument) DSL" do
      let(:klass) do
        Class.new.class_eval do
          Porcelain::Legacy::DSL[ self ]
          option_parser { }
          argument_syntax '<foo>'
          def bar foo ; end
          self
        end
      end
      context "allows you to associate a description" do
        let(:klass) do
          ohai = self
          Class.new.class_eval do
            Porcelain::Legacy::DSL[ self ]
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
        klass.actions[:bar].argument_syntax.string.should eql('<foo>')
      end
      context 'provides an argument syntax in which' do
        it "you can inspect the number of parameters (like nonternimal symbols)" do
          klass.actions[:bar].argument_syntax.length.should eql(1)
        end
        def _ str
          __(str).first
        end
        def __ str
           Porcelain::Legacy::Argument::Syntax.from_string(str)
        end
        context "a required parameter (a [1..1] ranged parameter)" do
          let(:parameter) {  _ '<foo>' }
          it("knows it is required") { parameter.is_required.should eql(true) }
          it("unparses correctly") { parameter.string.should eql('<foo>') }
        end
        context "an optional parameter (a [0..1] ranged parameter)" do
          let(:parameter) { _ '[<foo>]' }
          it("knows it is not required") { parameter.is_required.should eql(false) }
          it("unparses like so") { parameter.string.should eql('[<foo>]') }
        end
        context "a [1..] ranged parameter" do
          let(:parameter) { _ '<foo>[<foo>[...]]' }
          it("knows it is required") { parameter.is_required.should eql(true) }
          it("unparses like so") { parameter.string.should eql('<foo> [<foo>[...]]') }
          context do
            let(:parameter) { _ '<foo> [..]' }
            it("can also be notated this way") { parameter.is_required.should eql(true) }
            it("but unparses the same as above") { parameter.string.should eql('<foo> [<foo>[...]]') }
          end
        end
        context "a [0..] ranged parameter" do
          let(:parameter) { _ '[<foo> [<foo> [...]]]' }
          it("knows it is not required") { parameter.is_required.should eql(false) }
          it("unparses like so") { parameter.string.should eql('[<foo> [<foo>[...]]]') }
          context do
            let(:parameter) { _ '[<foo> [..]]' }
            it("can also be notated in this way") { parameter.is_required.should eql(false) }
            it("but unparses the same as above") { parameter.string.should eql('[<foo> [<foo>[...]]]') }
          end
        end
        context "glob" do
          it "can be one optional parameter at the end" do
            __('<a> [<b> [<b> [..]]]').length.should eql(2)
          end
          it "can be one required parameter at the end" do
            __('<a> <b> [<b> [..]]').length.should eql(2)
          end
          it "can be the only parameter, and required" do
            __('<a> [<a> [..]]').length.should eql(1)
          end
          it "can be the only parameter, and optional" do
            __('[<a> [<a> [..]]]').length.should eql(1)
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
        context "optional" do
          it "can occur more than once at the end" do
            __('<a> [<b>] [<c>]').length.should eql(3)
          end
          it "cannot occur at the beginning" do
            lambda{ __('[<a>] <b>') }.should raise_exception(/optionals cannot occur at the beginning/i)
          end
          it "cannot occur in the middle" do
            lambda{ __('<a> [<b>] <c>') }.should raise_exception(/optionals cannot occur in the middle/i)
          end
          context "can occur in conjunction with globs, provided the above rules are followed" do
            it "with a trailing optional glob" do
              __('<a> [<b>] [<c>] [<d> [<d> [..]]]').length.should eql(4)
            end
            it "but not with a trailing required glob, e.g." do
              lambda{ __('<a> [<b>] [<c>] <d> [<d> [..]]') }.should raise_exception(/optionals cannot occur in the middle/i)
            end
          end
        end # optional
        context "a syntax for arguments of" do
          let(:otherwise) { lambda { |msg| _stderr.puts msg ; false } }
          pen = Headless::CLI::Pen::MINIMAL
          define_method :pen do pen end
          context "zero-length" do
            let(:syntax) { Porcelain::Legacy::Argument::Syntax.from_string('').argument_syntax_subclient pen }
            it "against the zero-length args emits no errors and returns true" do
              syntax.validate(argv = [], otherwise).should eql(true)
              stderr.should eql('')
              argv.should eql([])
            end
            it "against a nonzero-length args emits an error and returns false" do
              syntax.validate(argv = %w(alpha beta), otherwise).should eql(false)
              stderr.should match(/unexpected argument/i)
              argv.should eql(%w(alpha beta))
            end
          end
          context "zero-or-one-length" do
            let(:syntax) { Porcelain::Legacy::Argument::Syntax.from_string('[<foo>]').argument_syntax_subclient pen }
            it "against the zero-length args emits no errors and returns true" do
              syntax.validate(argv = [], otherwise).should eql(true)
              stderr.should eql('')
              argv.should eql([])
            end
            it "against one-length args emits no errors and returns true" do
              syntax.validate(argv = ['first'], otherwise).should eql(true)
              stderr.should eql('')
              argv.should eql(['first'])
            end
          end
          context "zero-to-many length" do
            let(:syntax) { Porcelain::Legacy::Argument::Syntax.from_string('[<foo> [..]]').argument_syntax_subclient pen }
            it "against the zero-length args emits no errors and returns true" do
              syntax.validate(argv = [], otherwise).should eql(true)
              stderr.should eql('')
              argv.should eql([])
            end
            it "against one-length args emits no errors and returns true" do
              syntax.validate(argv = ['first'], otherwise).should eql(true)
              stderr.should eql('')
              argv.should eql(['first'])
            end
            it "against many-length args emits no errors and returns true" do
              syntax.validate(argv = ['first', 'second'], otherwise).should eql(true)
              stderr.should eql('')
              argv.should eql(['first', 'second'])
            end
          end
          context "a required, an optional, then a glob" do
            let(:syntax) { Porcelain::Legacy::Argument::Syntax.from_string('<foo> [<bar>] [<baz> [..]]').argument_syntax_subclient pen }
            it "against the zero-length args emits an error and returns false" do
              syntax.validate(argv = [], otherwise).should eql(false)
              stderr.should match(/expecting.+<foo>/)
              argv.should eql([])
            end
            it "against one is ok" do
              syntax.validate(argv = ['one'], otherwise).should eql(true)
              stderr.should eql('')
              argv.should eql(['one'])
            end
            it "againt five is ok" do
              syntax.validate(argv = %w(one two three four five), otherwise).should eql(true)
              stderr.should eql('')
              argv.should eql(%w(one two three four five))
            end
          end # n length
        end # of
      end # ArgumentSyntax
    end # DSL
    context "(part 3) invocation happens with a call to invoke() (pass it ARGV) that" do
      let(:expecting_foo_bar) { /expecting \{(?:help\|)?foo\|bar\}/i }
      let(:klass) do
        Class.new.class_eval do
          Callback[ self, :employ_DSL_for_digraph_emitter ]
          event_class Callback::Event::Textual
          Porcelain::Legacy::DSL[ self ]
          def foo ; end
          def bar ; end
        private
          def initialize( * )
            super
            @program_name = 'yourapp'
          end
          def baz ; end
          self
        end
      end
      it "with empty argv it complains, lists available actions and invites to more help" do
        instance.invoke []
        styled_stderr.should match(expecting_foo_bar)
        styled_stderr.should match(/try yourapp -h for help/i)
      end
      it "with a bad action name it complains, lists available actions and invites to more help" do
        instance.invoke ['derpis']
        styled_stderr.should match(/invalid action: derpis/i)
        styled_stderr.should match(expecting_foo_bar)
      end
      it "with -h or --help as the first argument, you get help (listing of avaiable commands)" do
        instance.invoke ['-h']
        styled_stderr.should match(/usage: yourapp \{(?:help\|)?foo\|bar\}/i)
        styled_stderr.should match(/for help on a particular subcommand/i)
      end
      it "with -h (or help) followed by an action name, you get action-specific help" do
        instance.invoke ['-h', 'foo']
        styled_stderr.should match(/usage: yourapp foo/i)
      end
      context "does fuzzy matching on the action name" do
        let(:klass) do
          Class.new.class_eval do
            Porcelain::Legacy::DSL[ self ]
            def pliny ; end
            def plone ; end
            self
          end
        end
        it "by default" do
          instance.invoke %w(pl)
          styled_stderr.should match(/ambiguous action[ ":]+pl/i)
          styled_stderr.should match(/did you mean pliny or plone/i)
        end
        context "but by using the config" do
          let(:klass) do
            Class.new.class_eval do
              Porcelain::Legacy::DSL[ self ]
              fuzzy_match false
              def pliny ; end
              def plone ; end
              self
            end
          end
          it "it can be turned off" do
            instance.invoke %w(pl)
            styled_stderr.should match(/invalid action[ :"]+pl/i)
            styled_stderr.should match(/expecting.+pliny\|plone/i)
          end
        end
      end
    end
    context "(part 4) when invoking an actions with no syntaxes defined (just public methods)" do
      let(:klass) do
        Class.new.class_eval do
          Porcelain::Legacy::DSL[ self ]
          attr_reader :argv, :touched
          private :argv, :touched
        private
          def initialize( * )
            super
            @touched = nil
            @program_name = 'yourapp'
          end
        public
          def takes_no_arguments
            @touched = true
          end
          self
        end
      end
      it "0  ) if no args are given it will enumerate the available actions (methods)" do
        instance.invoke []
        stderr = self.stderr
        stderr.should match(/expecting.+takes-no-arguments/i)
      end
      context "with one such action whose methods take no arguments" do
        it "1.0) if you pass it no arguments, it is called" do
          instance.invoke %w(takes-no-arguments)
          instance.send(:touched).should eql(true)
          stderr.should eql('')
        end
        it "1.1) if you pass it some arguments, it reports a syntax error and shows usage and invites for help" do
          i = instance
          i.invoke(%w(takes-no-arguments first-arg)).should eql(1)
          s = unstyle_styled( stderr ).split("\n")
          s.shift.should match(/unexpected argument[: ]+"first-arg"/i)
          s.shift.should match(/usage: yourapp takes-no-arguments/i)
          s.shift.should match(/try .* for help/i)
          s.size.should eql(0)
        end
      end
    end
    context "(part 5) provides rendering of" do
      let(:definition_block) do
        lambda do |_|
          option_parser do |o|
            o.on('-a', '--apple', "an apple")
            o.on('-p', '--pear[=foo]',  "a pear")
            o.on('--bananna=<type>', "a bananna")
          end
          argument_syntax '<foo> [<bar>]'
          def whatever_is_clever foo, bar=nil; end
        end
      end

      let(:klass) do
        this = self
        Class.new.class_eval do
          Porcelain::Legacy::DSL[ self ]
          class_eval(&this.definition_block)
        private
          def initialize( * )
            super
            @program_name = 'yourapp'
          end
          self
        end
      end
      context "syntax that provides more detail than optparse:" do
        subject do
          act = instance.send( :fetch_action_sheet, 'whatever-is-clever' ).
            action_subclient( instance )
          act.send :render_syntax_string
        end
        specify { should eql('yourapp whatever-is-clever [-a] [-p[=foo]] [--bananna=<type>] <foo> [<bar>]') }
      end
      context "help screens" do
        it "will use optparse's rendering of help screen for the options" do
          instance.invoke(%w(whatever-is-clever -h))
          help_screen = unstyle_styled stderr
          help_screen.should match(/usage: yourapp whatever-is-clever/i)
          help_screen.should match(/-a, --apple +an apple/)
        end
      end
    end # provides rendering
    context "(part 6) allows you to specify default actions (actually argvs), for e.g.:" do
      context 'with an app with actions "foo" and "bar"' do
        let(:klass) do
          o = self
          Class.new.class_eval do
            ::Skylab::Porcelain::Legacy::DSL[ self ]
            class_eval(& o.body)
            def foo
              call_digraph_listeners(:info, "I am foo.")
            end
            def bar
              call_digraph_listeners(:info, "I am bar.")
            end
            self
          end
        end
        def first_line
          instance.invoke argv
          stderr.match(/\A[^\n]+/)[0]
        end
        let(:subject) do
          first_line
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
          let(:body) { ->(_) { default_action_i :foo } }
          context 'against an argv with no arguments' do
            let(:argv) { [] }
            context "it will run foo - the output" do
              specify { should match(/^I am foo\.$/) }
            end
          end
          context "against an argv with [bar]" do
            let(:argv) { ['bar'] }
            context "it will run bar - the output" do
              specify { should match(/^I am bar\.$/) }
            end
          end
          context "against an argv with [baz]" do
            let(:argv) { ['baz'] }
            let(:subject) do
              unstyle_styled first_line
            end
            context "it does not invoke the default action - the output" do
              specify { should match(/Invalid action\: baz/i) }
            end
          end
        end
        context "that specifies a multi-argument default" do
          let(:body) { ->(_) { default_action_i :foo, ['-x'] } }
          context "it works" do
            let(:argv) { [] }
            specify { should match(/unexpected argument.+-x/i) }
          end
        end
      end
    end
    context "(part 7) With regards to Namespaces.." do
      context "Porcelain itself" do
        subject { Porcelain::Legacy }
        it { should_not respond_to(:namespaces) }  # tombstone of the past
      end
      if false # sorry
      context "if you try to use both an external class and an inline namespace definition"
      context "if you try to use neither external class nor internal namespace defnition"
      end

      let(:klass_with_inline_namespace) do
        Class.new.class_exec do
          Porcelain::Legacy::DSL[ self ]
          namespace :more do
            def tingle
              call_digraph_listeners(:info, "yes sure tingle inline")
              :yes_tingle
            end
          end
          def duckle ; end
        private
          def initialize( * )
            super
            @program_name = 'wahoo'
          end
          self
        end
      end
      let(:klass_for_namespace) do
        Class.new.class_eval do
          Porcelain::Legacy::DSL[ self ]
          def tingle
            call_digraph_listeners(:info, "yes sure tingle external")
            :yes_tingle
          end
          def initialize rc, as
            super
            @program_name = 'zappersbury'  # don't see? b.c of what happnes
          end
          self
        end
      end
      let(:klass_with_external_namespace) do
        o = self
        Class.new.class_eval do
          Porcelain::Legacy::DSL[ self ]
          namespace :'more', o.klass_for_namespace
          def duckle ; end
          def initialize stdup, stdpay, stdinfo
            super
            @program_name = 'wahoo'
          end
          self
        end
      end
      context "(sanity check regression)" do
        it "namespace class action names look ok" do
          klass_for_namespace.actions.map(&:normalized_local_action_name).should eql([:help, :tingle])
        end
        it "class with inline namespace action names look ok" do
          klass_with_inline_namespace.actions.map(&:normalized_local_action_name).should eql([:help, :more, :duckle])
        end
        it "class with external namespace action names look ok" do
          klass_with_external_namespace.actions.map(&:normalized_local_action_name).should eql([:help, :more, :duckle])
        end
      end
      context "(class with inline namespace regression)" do
        it "does" do
          namespace_sheet = klass_with_inline_namespace.actions[:more]
          kls = namespace_sheet.send :action_class
          kls.story.actions.map(&:normalized_local_action_name).should(
            eql([:help, :tingle])
          )
        end
      end
      a = [ ]
      a << { name: 'an external class', var: :klass_with_external_namespace }
      a << { name: 'an inline namespace definition', var: :klass_with_external_namespace }
      a.each do |o|

        name, var = %w(name var).map { |k| o[k.intern] }

        context "when you have <<#{name}>>.." do

          let(:klass) { send(var) }

          context "stdout response" do

            before do
              @result = instance.invoke argv
            end

            # subject { style_free stderr.split("\n").first }
            subject do
              a = stderr.split("\n").first
              b = style_free a
              b
            end

            context "[] (0)" do
              let(:argv) { [] }
              specify { should match(/expecting.*more.*duckle/i) }
            end
            context "-h (1.4)" do
              let(:argv) { %w(-h) }
              specify { should match(/^usage: wahoo \{ *more *\| *duckle *\}/) }
            end
            context "foo (1.1)" do
              let(:argv) { %w(foo) }
              specify { should match(/invalid action: foo/i) }
            end
            context "more (2.0)" do
              let(:argv) { %w(more) }
              specify { should match(/expecting.+tingle/i) }
            end
            context "more -h (2.4)" do
              let(:argv) { %w(more -h) }
              specify do
                should match(/^usage.*wahoo.*more.*tingle.*opts.*args/i)
              end
            end
            context "more wang (2.1)" do
              let(:argv) { %w(more wang) }
              specify { should match(/invalid action: wang/i) }
            end
            context "more tingle foo (2.5)" do
              let(:argv) { %w(more tingle foo) }
              specify { should match(/unexpected argument.*foo/i) }
            end
            context "more tingle -h (3.3)" do
              let(:argv) { %w(more tingle -h) }
              specify { should match(/^usage: wahoo more tingle/i) }
            end
            context "more tingle (2.3)" do
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
          ::Skylab::Porcelain::Legacy::DSL[ self ]
          module_eval(& o.body)
        private
          def initialize( * )
            super
            @program_name = 'doipus'
          end
          self
        end
      end
      let(:subject) do
        @return = instance.invoke argv
        style_free( stderr.match(/\A[^\n]+/)[0] )
      end
      context "basic one arg def" do
        let(:body) do
          lambda do |_|
            def foo first
              call_digraph_listeners(:info, "i am foo with: #{first}.")
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
              call_digraph_listeners(:info, "i am foo with: #{first}, #{second}.")
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
              should raise_exception(ArgumentError, /wrong number of arguments \(3 for 1..2\)/)
          end
        end
      end
    end
  end
end

