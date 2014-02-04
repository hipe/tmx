require_relative 'test-support'

module Skylab::Face::TestSupport::Plugin

  describe "[hl] plugin" do  # loaded late for coverage

    context "basic - just host with nothing" do
      it "the module graph builds." do
        module M1
          class PH
            Plugin_::Host.enhance self
          end
        end
      end
    end

    def self.anchor f
      memo = -> do
        res = f.call
        memo = -> { res }
        res
      end
      define_method :anchor_module do
        memo[ ]
      end
    end

    context "basic - create plugin" do

      anchor -> do
        module M4
          class PI
            Plugin_.enhance self
          end
          self
        end
      end

      it "builds" do
        plugin
      end
    end

    context "basic - add hot plugin" do

      anchor -> do
        module M3
          class PH
            Plugin_::Host.enhance self
          end
          self
        end
      end

      it "`attach_hot_plugin` won't work with whatever - you need some hooks" do
        -> do
          host.instance_exec do
            attach_hot_plugin :x
          end
        end.should raise_error( ::NoMethodError,
          /undefined method `receive_plugin_attachment_notification/ )
      end
    end

    let :host do
      host_class.new
    end

    def host_class
      anchor_module.const_get :PH, false
    end

    context "basic - module as plugin" do

      anchor -> do
        module M10
          module P1
            Plugin_.enhance self
          end
          class P2
            Plugin_.enhance self
          end
          self
        end
      end

      it "they both can hear eventpoints" do
        anchor_module  # kick :/
        p1 = M10::P1::Client.new
        p2 = M10::P2.new

        p1.respond_to?( :receive_plugin_eventpoint_notification ).
          should eql( true )
        p2.respond_to?( :receive_plugin_eventpoint_notification ).
          should eql( true )
      end
    end

    context "service - host - declare service it has" do
      anchor -> do
        module M13
          class PH
            Plugin_::Host.enhance self do
              services :c, [ :d ]
            end
          end
          self
        end
      end

      before :each do anchor_module end

      it "builds" do
      end

      it "reflects (privately) - though `services`" do
        host.send( :plugin_host_story ).services
      end

      def svcs
        host.send( :plugin_host_story ).services
      end

      it "reflects - has?" do
        svcs.has?( :c ).should eql( true )
        svcs.has?( :d ).should eql( true )
        svcs.has?( :e ).should eql( false )
      end

      it "reflects - `names`" do
        svcs.get_names.should eql( [ :c, :d ] )
      end
    end

    context "service - host - re-entrant" do
      anchor -> do
        module M28
          class PH
            Plugin_::Host.enhance self do
              services :foo, :bar
            end
            Plugin_::Host.enhance self do
              services :baz
            end
          end
          self
        end
      end

      it "do" do
        host.send( :plugin_host_story ).services._a.
          should eql( [ :foo, :bar, :baz ] )
      end
    end

    context "service - host - strange directives bark with helpful msg" do
      it "like so" do
        -> do
          module M26
            class X
              Plugin_::Host.enhance self do
                services [ :wiffle, :xyzzy, :no_see ]
              end
            end
          end
        end.should raise_error( Plugin_::DeclarationError,
          /unexpected token :xyzzy, expecting .+ for defining #{
            }this .+\bHost.+Service_\b/ )
      end
    end

    context "service - integration - compatibility is checked at attachment" do
      anchor -> do
        module M14
          class PH
            Plugin_::Host.enhance self do
              services :beep, :zeep
            end
          end

          class PI_A
            Plugin_.enhance self do
              services_used :beep, :feep, :meep
            end
          end

          class PI_B
            Plugin_.enhance self do
              services_used :zeep
            end
          end
          self
        end
      end

      before :each do anchor_module end

      it "when pi wants nonexistent svc - borks like mork at attach time" do
        -> do
          host.send :attach_hot_plugin, M14::PI_A.new
        end.should raise_error( Plugin_::DeclarationError,
          /\bPH has not declared the required services \(feep, meep\) #{
            }declared as needed by .+\bPI/ )
      end
    end

    def call_svc *a
      host.plugin_host_metaservices.call_service( *a )
    end

    context "service - host - via `method` is default" do
      anchor -> do
        module M15
          class PH
            Plugin_::Host.enhance self do
              services :meep, :zeep
            end

            def zeep one, two
              "<#{ one }-#{ two }>"
            end
          end
          self
        end
      end

      it "call a service that is not declared - decl error" do
        -> do
          call_svc :beep
        end.should raise_error( Plugin_::DeclarationError,
          /"beep" has not been declared .+ service of this host.+\bM15::PH\z/ )
      end

      it "call a service that is not implemented - fails as-is" do
        -> do
          call_svc :meep
        end.should raise_error( ::NoMethodError, /undefined method `meep'/ )
      end

      it "do" do
        call_svc( :zeep, ['a','b'] ).should eql('<a-b>')
      end
    end

    context "service - host - via `method` <method-name>" do
      anchor -> do
        module M25
          class PH
            Plugin_::Host.enhance self do
              services [ :wat, :method, :wat_as_service ]
            end

            def wat_as_service a, b
              [ :ok, "<<#{ a }<->#{ b }>>" ]
            end
          end
          self
        end
      end

      it "do" do
        call_svc( :wat, [ :x, :y ] ).should eql( [ :ok, "<<x<->y>>" ] )
      end
    end

    context "service - host - via `ivar`" do
      anchor -> do
        module M16
          class PH
            Plugin_::Host.enhance self do
              services [ :doink, :ivar ]
            end

            def initialize
              @doink = :x
            end
          end
          self
        end
      end

      before :each do anchor_module end

      it "compile" do
      end

      it "do" do
        call_svc( :doink ).should eql( :x )
      end
    end

    context "service - host - via `ivar` :@foo" do
      anchor -> do
        module M29
          class PH
            Plugin_::Host.enhance self do
              services [ :doink, :ivar, :@derk ]
            end

            def initialize
              @derk = :x
            end
          end
          self
        end
      end

      it "do" do
        call_svc( :doink ).should eql( :x )
      end
    end

    context "service - host - via `dispatch` <method-name> <arg1>" do
      anchor -> do
        module M30
          class PH
            Plugin_::Host.enhance self do
              services [ :truffle, :dispatch, :choc_factory, :trfl ],
                       [ :bon_bon, :dispatch, :choc_factory, :bb ]
            end
          private
            def choc_factory which
              "<#{ which }>"
            end
          end
          self
        end
      end

      it "compile" do
        anchor_module
      end

      it "do" do
        call_svc( :truffle ).should eql( '<trfl>' )
        call_svc( :bon_bon ).should eql( '<bb>' )
      end
    end

    context "service - host - via `dispatch` <method-name> [ N args ]" do
      anchor -> do
        module M31
          class PH
            Plugin_::Host.enhance self do
              services [ :zagnut, :dispatch, :choc_factory, nil ],
                       [ :ho_ho, :dispatch, :choc_factory, [ :a, :b ] ]
            end
          private
            def choc_factory *a, &b
              "<#{ a * ',' }#{ b['hi'] if b }>"
            end
          end
          self
        end
      end

      it "do no args in either place" do
        call_svc( :zagnut ).should eql( '<>' )
      end

      it "some args in declaration, some args in call, and a block!" do
        call_svc( :ho_ho, [ :c, :d ], -> x { "(#{ x })" } ).
          should eql( '<a,b,c,d(hi)>' )
      end
    end

    context "service - plugin - declare service it needs" do
      anchor -> do
        module M12
          class X
            Plugin_.enhance self do
              services_used :a, [:b]
            end
          end
          self
        end
      end

      before :each do anchor_module end

      it "builds" do
      end

      it "reflects through `services_used`" do
        M12::X.plugin_story.services_used
      end

      it "which has `has?`" do
        M12::X.plugin_story.services_used.has?( :a ).should eql( true )
        M12::X.plugin_story.services_used.has?( :b ).should eql( true )
        M12::X.plugin_story.services_used.has?( :c ).should eql( false )
      end

      it "which gets names through `names`" do
        M12::X.plugin_story.services_used.get_names.should eql( [ :a, :b ] )
      end
    end

    context "service - plugin (integrated) - default is to absorb it as i.m" do
      anchor -> do
        module M32
          class PH
            Plugin_::Host.enhance self do
              services :bliff
            end
            def bliff ; :fliff end
          end
          class PI
            Plugin_.enhance self do
              services_used :bliff
            end
            def run
              bliff
            end
          end
          self
        end
      end
      it "do" do
        graph
        plugin.run.should eql( :fliff )
      end
    end

    context "service - plugin (integrated) - `method` <method-name>" do
      anchor -> do
        module M33
          class PH
            Plugin_::Host.enhance self do
              services :floof
            end
            def floof ; :boof end
          end
          class PI
            Plugin_.enhance self do
              services_used [ :floof, :method, :floof_service ]
            end
            def run
              floof_service
            end
          end
          self
        end
      end

      it "do" do
        graph
        plugin.run.should eql( :boof )
      end
    end

    context "service - plugin (integrated) - `ivar`" do
      anchor -> do
        module M20
          class PH
            Plugin_::Host.enhance self do
              services :clerkemer, [ :derkemer, :ivar ]
            end

            def initialize
              @derkemer = :the_d
            end

            def clerkemer
              :the_c
            end
          end

          class PI
            Plugin_.enhance self do
              services_used [ :clerkemer, :ivar ],
                [ :derkemer, :ivar, :@flerkemer ]
            end
          end
          self
        end
      end

      before :each do anchor_module end

      it "compile" do
      end

      it "do" do
        graph
        pi = plugin
        pi.instance_variable_get( :@clerkemer ).should eql( :the_c )
        pi.instance_variable_get( :@flerkemer ).should eql( :the_d )
      end
    end

    let :plugin do
      plugin_class.new
    end

    def plugin_class
      anchor_module.const_get :PI, false
    end

    def parent_svcs
      plugin.instance_variable_get( :@plugin_parent_services )
    end

    context "service - plugin (integrated) - `proxy`" do
      anchor -> do
        module M34
          class PH
            Plugin_::Host.enhance self do
              services :foo, :bar, :biff, :baz, :blimmo, :blammo
            end
          private
            def foo  ; fail 'never see' end
            def bar  ; '(bar)' end
            def biff ; :BIFF end
            def baz  ; :BAZ  end
            def blimmo x, y ; "<#{ x }-#{ y }>" end
            def blammo &blk
              "_#{ blk.call }_"
            end
          end
          class PI
            Plugin_.enhance self do
              services_used :bar, [ :biff, :proxy ], [ :baz, :proxy ],
                [ :blimmo, :proxy ], [ :blammo, :proxy ]
            end
          end
          self
        end
      end

      before :each do
        graph
      end

      it "compile" do
      end

      it "call svc not declared at all (from plugin side) - ok" do
        -> do
          parent_svcs.foo
        end.should raise_error( Plugin_::DeclarationError,
          /the "foo" service must be but was not.+M34::PI/ )
      end

      it "call svc decleared, but not as `proxy` - OK" do
        parent_svcs.bar.should eql( '(bar)' )
      end

      it "call svc declared as proxy - niladic" do
        parent_svcs.biff.should eql( :BIFF )
      end

      it "call svc delcared as proxy - diadic" do
        parent_svcs.blimmo( :a, :b ).should eql( '<a-b>' )
      end

      it "call svc declared as proxy - block" do
        parent_svcs.blammo{ :hi }.should eql( '_hi_' )
      end

      it "with `[]` call a totally nonexistant service - quacks" do
        -> do
          parent_svcs[ :blizzo ]
        end.should raise_error( Plugin_::DeclarationError,
          /the "blizzo" service must be but was not declared as #{
            }subscribed to/ )
      end

      it "with `[]` call a service that the pi did not declare at all" do
        -> do
          parent_svcs[ :foo ]
        end.should raise_error( Plugin_::DeclarationError,
          /the "foo" service must be but was not declared as subscribed #{
            }to by the .+\bPI" plugin/i )
      end

      it "with `[]` call a svc that the pi did NOT declare as `proxy` - OK!" do
        parent_svcs[ :bar ].should eql( '(bar)' )
      end

      it "with `[]` call a single svc (declared as proxy)" do
        parent_svcs[ :biff ].should eql( :BIFF )
      end

      it "with `[]` call multiple svcs" do
        parent_svcs[ :biff, :baz ].should eql( [ :BIFF, :BAZ ] )
      end
    end

    # --*--

    context "eventpoint - host - declare, emit" do

      anchor -> do
        module M2
          class PH
            Plugin_::Host.enhance self do
              eventpoints :foo, [ :bar ]
            end
          end
          self
        end
      end

      it "emits declared eventpoints" do
        host.instance_exec do
          emit_eventpoint :foo
          emit_eventpoint :bar
        end
      end

      it "emitting an undeclared eventpoint - raises" do
        -> do
          host.send :emit_eventpoint, :baz
        end.should raise_error( Plugin_::DeclarationError,
                               /undeclared.+baz.+\bdeclared.+foo.+bar/i )
      end
    end

    context "eventpoint - plugin - subscribe" do

      anchor -> do
        module M5
          class PI
            Plugin_.enhance self do
              eventpoints_subscribed_to :zip, [ :zap ]
            end
          end
          self
        end
      end

      it "builds" do
        plugin
      end

      it "reflects" do
        plugin_class.plugin_story.eventpoints.get_names.
          should eql( [ :zip, :zap ] )
      end
    end

    context "eventpoint - integration - pi verify (is subset) at attachment" do
      anchor -> do
        module M6
          class PH
            Plugin_::Host.enhance self do
              eventpoints :zaff, :ziff
            end
          end
          class PI
            Plugin_.enhance self do
              eventpoints_subscribed_to :zeeple, :ziff, :deeple
            end
          end
          self
        end
      end

      it "barks like clark" do
        -> do
          host.send :attach_hot_plugin, plugin
        end.should raise_error( Plugin_::DeclarationError,
          /unrecognized eventpoint\(s\) subscribed #{
            }to by .+M6::PI.+\(zeeple, deeple\)/i )
      end
    end

    context "eventpoint - integration - pi IFF attached to host receives" do
      anchor -> do
        module M7
          class PH
            Plugin_::Host.enhance self do
              eventpoints :zaff, :ziff
            end
          end
          class PI
            Plugin_.enhance self do
              eventpoints_subscribed_to :ziff
            end
            attr_accessor :touched
          private
            def receive_ziff_plugin_eventpoint
              self.touched = true
            end
          end
          self
        end
      end

      it "watch the magic" do
        p = plugin
        host.instance_exec do
          attach_hot_plugin p
          emit_eventpoint :ziff
        end
        p.touched.should eql( true )
      end

      it "plugin won't get unsubscribed events" do
        p = plugin
        host.instance_exec do
          attach_hot_plugin p
          emit_eventpoint :zaff
        end
        p.touched.should eql( nil )
      end
    end

    context "eventpoint - integration - host pass args to plugin" do
      anchor -> do
        module M8
          class PH
            Plugin_::Host.enhance self do
              eventpoints :foo
            end
          end
          class PI
            Plugin_.enhance self do
              eventpoints_subscribed_to :foo
            end
            attr_reader :canary
            def receive_foo_plugin_eventpoint one, two
              @canary = "<#{ one }-#{ two }>"
            end
          end
          self
        end
      end

      it "yes" do
        p = plugin
        host.instance_exec do
          attach_hot_plugin p
          emit_eventpoint :foo, :a, :b
        end
        p.canary.should eql( '<a-b>' )
      end
    end

    context "eventpoint - integration - pi receive arguments from host - DSL" do
      anchor -> do
        module M9
          class PH
            Plugin_::Host.enhance self do
              eventpoints :ziff
            end
          end
          class PI
            Plugin_.enhance self do
              eventpoints_subscribed_to :ziff
            end

            ziff do |a, b|
              @yup = "<<#{ a }_#{ b }>>"
            end

            attr_reader :yup
          end
          self
        end
      end

      it "builds" do
        plugin
      end

      it "receives" do
        p = plugin
        host.instance_exec do
          attach_hot_plugin p
          emit_eventpoint :ziff, :one, :two
        end
        p.yup.should eql( '<<one_two>>' )
      end
    end

    let :graph do
      host.send :attach_hot_plugin, plugin
      nil
    end

    context "eventpoint - integration - pi define simple result tuple w DSL" do
      anchor -> do
        module M18
          class PH
            Plugin_::Host.enhance self do
              eventpoints :wenk
            end
          end
          class PI
            Plugin_.enhance self do
              eventpoints_subscribed_to :wenk
            end
            wenk :tenk, :menk
          end
          self
        end
      end

      it "compile" do
        anchor_module
      end

      it "do" do
        graph
        host.send :emit_eventpoint, :wenk do |pi, x1, x2|  # etc
          pi.plugin_metaservices.moniker.should match( /\bM18::PI\b/ )
          [ x1, x2 ].should eql( [ :tenk, :menk ] )
        end
      end
    end

    context "eventpoint - integration - pi receive & respond tuples w YIELD" do
      anchor -> do
        module M19
          class PH
            Plugin_::Host.enhance self do
              eventpoints :boink
            end
          end
          class PI
            Plugin_.enhance self do
              eventpoints_subscribed_to :boink
            end
            boink do |a1, a2, a3, &blk|
              blk[ "#{ a1 }_#{ a2 }_#{ a3 }", :hi ]
            end
          end
          self
        end
      end

      it "compile" do
        graph
      end

      it "do" do
        graph
        host.send( :emit_eventpoint, :boink, :one, :two, :three ) do |pi, y, z|
          pi.plugin_metaservices.moniker.should match( /\bM19::PI\b/ )
          [ y, z ].should eql( [ 'one_two_three', :hi ] )
        end
      end
    end

    context "eventpoint - integration - `emit_customized_eventpoint`" do
      anchor -> do
        module M24
          class PH
            Plugin_::Host.enhance self do
              eventpoints :foo
              plugin_box_module -> { Plugins }
            end
          end
          module Plugins
            class PugbertOne
              Plugin_.enhance self do
                eventpoints_subscribed_to :foo
              end
              foo do |a, b, &y|
                y[ "#{ a }:#{ b }", :hey ]
              end
            end
            class PugbertTwo
              Plugin_.enhance self do
                eventpoints_subscribed_to :foo
              end
              foo do |a, b, &y|
                y[ "#{ b }:#{ a }", :hi ]
              end
            end
          end
          self
        end
      end

      it "do (also, `local_plugin_moniker`)" do
        a = [ ]
        host.send :emit_customized_eventpoint, :foo, -> pi do
          [ pi.local_plugin_moniker, :baz ]
        end do |pi, x, y|
          a << x ; a << y
          nil
        end
        a.should eql( ["pugbert-one:baz", :hey, "baz:pugbert-two", :hi] )
      end
    end

    context "determine available plugin - via box modules" do
      anchor -> do
        module M11
          class PH
            Plugin_::Host.enhance self do
              plugin_box_module -> { Plugins }
            end
          end
          module Plugins
          end
          module Plugins::P1
            Plugin_.enhance self
          end
          class Plugins::P2
            Plugin_.enhance self
          end
          self
        end
      end

      it "hot_a is plugin objects properly determined" do
        a = nil
        host.instance_exec do
          a = hot_plugin_a.map do |x|
            x.respond_to? :receive_plugin_eventpoint_notification
          end
        end
        a.should eql( [ true, true ] )
      end

      it "they automatically get names extruded from module names" do
        a = nil
        host.instance_exec do
          a = hot_plugin_a.map do |pi|
            pi.plugin_metaservices.name_function.as_slug
          end
        end
        a.should eql( [ 'p1', 'p2' ] )
      end
    end

    context "metastory - host" do
      anchor -> do
        module M21
          class PH
            Plugin_::Host.enhance self
          end
          self
        end
      end

      it "metastory is a thing" do
        host.plugin_metastory
      end

      it "host is host" do
        host.plugin_metastory.is_host.should eql( true )
      end

      it "host is not plugin" do
        host.plugin_metastory.is_plugin.should eql( false )
      end
    end

    context "metastory - plugin" do
      anchor -> do
        module M22
          class PI
            Plugin_.enhance self
          end
          self
        end
      end

      it "plugin is plugin" do
        plugin.plugin_metastory.is_plugin.should eql( true )
      end

      it "plugin is not host" do
        plugin.plugin_metastory.is_host.should eql( false )
      end
    end

    context "metastory - hybrid" do
      anchor -> do
        module M23
          class Hybrid_
            Plugin_::Host.enhance self
            Plugin_.enhance self
          end

          PH = Hybrid_
          PI = Hybrid_

          self
        end
      end

      it "hybrid is plugin" do
        plugin.plugin_metastory.is_host.should eql( true )
      end

      it "hybrid is host" do
        host.plugin_metastory.is_host.should eql( true )
      end
    end

    context "delegatee is terrible idea" do
      anchor -> do
        module M17
          class PH
            Plugin_::Host.enhance self do
              services [ :bling, :delegatee, :Nerkulous ]
            end
          end
          class PI_A
            Plugin_::Host.enhance self do
              services :bling
            end
            Plugin_.enhance self
            def bling
              :zingo
            end
          end
          class PI_B
            Plugin_.enhance self do
              services_used :bling
            end
            def execute
              bling
            end
          end
          self
        end
      end

      before :each do anchor_module end

      it "compile" do
      end

      let :graph do
        pi_a = M17::PI_A.new ; pi_b = @agent_pi = M17::PI_B.new
        host.send :attach_hot_plugin_with_name, pi_a, :Nerkulous
        host.send :attach_hot_plugin, pi_b
        nil
      end

      def agent_pi
        graph
        @agent_pi
      end

      it "do", wip:true do
        rs = agent_pi.execute
        rs.should eql( :zingo )
      end
    end

    TestSupport::Coverage::Muncher.munch '--cover', ::STDERR,
      -> do
        Face::Plugin.dir_pathname.to_s
      end, ::ARGV
  end
end
