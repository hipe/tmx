require_relative 'test-support'

module Skylab::Basic::TestSupport::List::Aggregated

  ::Skylab::Basic::TestSupport::List[ Aggregated_TestSupport = self ]

  include CONSTANTS

  extend TestSupport::Quickie

  module Sandbox
  end

  CONSTANTS::Sandbox = Sandbox  # mine and mine

  describe "#{ Basic }::List::Aggregated::Articulation WAHOO" do

    extend Aggregated_TestSupport

    context "normal" do

      define_sandbox_constant :func do
        Sandbox::F_1 = Basic::List::Aggregated.Articulation do
          template "{{ store }}{{ adj1 }} has the required {{ item }}#{
            } needed by {{ needer }}{{ adj2 }}"
          on_zero_items -> { "nothing happened." }
          aggregate do
            item -> a do
              if 1 == a.length then "item \"#{ a.fetch 0 }\""
              else                  "items (#{ a * ', ' })" end
            end
          end
          on_first_mention do
            store needer -> x do
              x.to_s.upcase
            end
            _flush -> x='WAT' do  # #todo:next
              "#{ x }."
            end
          end
          on_subsequent_mentions do
            store  -> { 'it' }
            adj1   -> { ' also' }
            needer -> { 'that needer' }
            adj2   -> { ' too' }
            _flush -> x='WHOSE' do  # #todo:next
              " #{ x }."
            end
          end
        end
      end

      it "none - \"nothing happened\"" do
        flush 'nothing happened.'
      end

      it "one - says first things first" do
        push 'iOS programming', 'excitement', 'me'
        flush "IOS PROGRAMMING has the required item \"excitement\" #{
          }needed by ME."
      end

      it "two inputs, one frame, aggregate two items please." do
        push 'scala', 'thrill', 'me'
        push 'scala', 'ecstasy', 'me'
        flush 'SCALA has the required items (thrill, ecstasy) needed by ME.'
      end

      it "two inputs, left same" do
        push 'haskell', 'fun', 'rob'
        push 'haskell', 'challenge', 'me'
        flush "HASKELL has the required item \"fun\" needed by ROB. it also #{
          }has the required item \"challenge\" needed by ME too."
      end

      it "three inputs, left has two, right always same" do
        push 'clojure', 'wanky', 'me'
        push 'clojure', 'danky', 'me'
        push 'scala',   'panky', 'me'
        flush "CLOJURE has the required items (wanky, danky) needed by ME. #{
         }SCALA also has the required item \"panky\" needed by that needer too."
      end

      Frame_ = ::Struct.new :store, :item, :needer

      attr_reader :queue_a

      def push *store_item_needer
        ( @queue_a ||= [ ] ) << Frame_[ * store_item_needer ]
        nil
      end

      def flush exp
        act = func.call( queue_a || [ ] )
        act.should eql( exp )
      end
    end
  end
end
