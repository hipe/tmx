require_relative 'test-support'

module Skylab::Face::TestSupport::CLI::Client::API_Integration::WNS

  ::Skylab::Face::TestSupport::CLI::Client::API_Integration[ self, :CLI_sandbox]

  describe "[fa] CLI client API integration - with namespace" do

    extend CLI_Client_TS_
    extend TS__  # so CONSTANTS (Sandbox) is visible in i.m's

    context "some basic tests of touching cli actions 3 and 4 levels deep" do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_1
          module CLI
            class Client < Face_::CLI::Client
              namespace :'bee-nee' do
                def dee
                  :deex
                end

                def fee_mee
                  @mechanics.normal_last_invocation_string
                end
              end

              namespace :gee do
                namespace :hee do
                  def jee
                    :jeex
                  end

                  use [ :normal_last_invocation_string ]

                  def kee_kee
                    normal_last_invocation_string
                  end
                end
              end
            end
          end
        end
      end

      it 'touch the monkey - 3 deep' do
        r = invoke 'bee-nee', 'dee'
        r.should eql( :deex )
      end

      it '`lhnis` - 3 deep' do
        r = invoke 'bee-nee', 'fee-mee'
        r.should eql( 'wtvr bee-nee fee-mee' )
      end

      # level 1 is modality client (not our scope). level 0 is human.

      it 'touch the monkey - 4 deep' do
        x = invoke 'gee', 'hee', 'jee'
        x.should eql( :jeex )
      end

      it '`normal_last_invocation_string` (with `use`)- level 4' do
        x = invoke 'gee', 'hee', 'kee-kee'
        x.should eql( "wtvr gee hee kee-kee" )
      end
    end

    context "test the `api` command's ability to .. work." do
      define_sandbox_constant :application_module do
        module Sandbox::Nightclub_2
          module API
            module Actions
              module BeeNee
                class Dee < Face_::API::Action
                  def execute
                    :deex
                  end
                end
                class Eee < Face_::API::Action
                  params [:one], [:two]
                end
                class Fee < Face_::API::Action
                  params :x, [ :y, :arity, :zero_or_one ]
                  def execute
                    "(#{ @x } and #{ @y.inspect })"
                  end
                end
              end
              module Gee
                module Hee
                  class Jee < Face_::API::Action
                    params :x
                    def execute
                      "nice work sailor: #{ @x }"
                    end
                  end
                end
              end
            end
          end
          module CLI
            class Client < Face_::CLI::Client
              namespace :'bee-nee' do
                use :api, :call_api
                def cee
                  api  # no corresponding.
                end
                def dee # yes corresponding, 3 deep
                  api
                end
                def eee  # takes params, none provided
                  api
                end
                def fee x, y=nil
                  api x, y
                end
                def gee
                  call_api [ :'bee-nee', :fee ], { x: 'ex', y: 'why' }
                end
              end

              namespace :gee do
                namespace :hee do
                  def jee x  # yes four deep, and pass 1 param
                    @mechanics.api x
                  end
                end
              end
            end
          end
        end
      end

      it '3 deep, no corresponding api action - runtime error' do
        -> do
          invoke 'bee-nee', 'cee'
        end.should raise_error(  # (the particular class is asserted elsehwere)
          /isomorphic API action resolution failed - .+"cee"/i )
      end

      it '3 deep, corresponding api action' do
        r = invoke 'bee-nee', 'dee'
        r.should eql( :deex )
      end

      it '3 deep, corres api action, takes some params, but none provided' do
        -> do
          invoke 'bee-nee', 'eee'
        end.should raise_error( ::ArgumentError,
          /missing required parameter.*s.+one.+two/i
        )
      end

      it '3 deep, corres api action, takes some params, one arg provided' do
        r = invoke 'bee-nee', 'fee', 'EX'
        r.should eql( '(EX and nil)' )
      end

      it '3 deep, call another api action' do
        r = invoke 'bee-nee', 'gee'
        r.should eql( '(ex and "why")' )
      end

      it '3 deep, corres api action, takes some params, both are provided' do
        r = invoke 'bee-nee', 'fee', 'EX', 'WHY'
        r.should eql( '(EX and "WHY")' )
      end

      it '4 deep, corres api action, takes some params' do
        debug!
        r = invoke 'gee', 'hee', 'jee', 'moon'
        r.should eql( "nice work sailor: moon" )
      end
    end
  end
end
