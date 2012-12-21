require_relative 'test-support'

module Skylab::MyTree::TestSupport

  describe "#{MyTree} CLI (this is frontier for headless push-up)" do
    extend ::Skylab::MyTree::TestSupport


    let( :action_summary_line_rx ) { /\A  [^ ].*\z/ }
    let( :_expecting_rx ) { /expecting {nerk\|tree}/ }
    let( :expecting_rx ) { /\A#{_expecting_rx.source}\z/ }
    let( :invite_rx ) { /\Ause mt -h \[<action>\] for help/ }
    let( :multiline_desc_line_rx ) { /\A  [^ ].*\z/ }
    let( :option_summary_first_line_rx ) { action_summary_line_rx }
    let( :usage_rx ) { /\Ausage: mt \[-h\] \[<action>\] \[<args> \[..\]\]\z/ }


    it "0   : no args : expecting / usage / invite" do
      response = invoke
      line.should match( expecting_rx )
      line.should match( usage_rx )
      line.should match( invite_rx )
      queue.should be_empty
      response.should be_nil
    end


    it "1.1 : one unrec arg : msg / usage / invite" do
      response = invoke 'gah'
      line.should match( /\Athere is no "gah" action\. #{
                                _expecting_rx.source }\z/ )
      line.should match( usage_rx )
      line.should match( invite_rx )
      queue.should be_empty
      response.should be_nil
    end


    it "1.2 : one unrec opt : msg / usage / invite" do
      response = invoke '-x'
      line.should match(/\Ainvalid option: -x\z/)
      line.should match( usage_rx )
      line.should match( invite_rx )
      queue.should be_empty
      response.should be_nil
    end


    it "1.3 : one opt: -h :  1) usage  2) desc  3) opts #{
      }4) action list  5) custom invite" do
      response = invoke '-h'
      line.should match( usage_rx )
      line.should eql('')

      line.should match( /\Adescription:\z/ )
      l = line
      begin
        l.should match( /\A[[:space:]]{2,}[^[:space:]]/ )
        l = line
      end while ( l && '' != l )

      line.should match( /\Aoptions:\z/ )
      line.should match( option_summary_first_line_rx )
      loop do
        '' == (l = line) and break
        l.should match( option_summary_first_line_rx )
      end

      line.should match( /\Aactions:\z/ )
      line.should match( action_summary_line_rx ) # one or more of these
      loop do
        '' == (l = line) and break
        l.should match( action_summary_line_rx )
      end
      line.should match(
        /\Ause mt -h <action> for help on that action\z/ )
      queue.should be_empty
      response.should be_nil
    end


    # #todo: single line desc       #todo: no-line descs


    it "2.2 : -h rec (leaf) arg : 1) usage 2) desc 3) opts descs 4) args desc" do
      response = invoke '-h', 'tree'
      line.should match( /\Ausage: mt tree/ )
      line.should eql('')
      line.should match(/\Aoptions:\z/)
      line.should match( option_summary_first_line_rx )
      while l = line
        if l != '' # allow blank lines within this last section
          l.should match( option_summary_first_line_rx )
        end
      end
      queue.should be_empty
      response.should be_nil
    end


    # #todo: -h rec branch arg


    it "2.1 : -h unrec arg : just like (1.1)" do
      response = invoke '-h', 'florp'
      line.should match( /\Athere is no "florp" action. #{
                                 _expecting_rx.source }\z/ )
      line.should match( usage_rx )
      line.should match( invite_rx )
      queue.should be_empty
      response.should be_nil
    end


    it "3.1 : -h rec arg <rest> : rest is ignored" do
      result = invoke '-h', 'tree', 'bleep'
      line.should match(/\A\(ignoring: "bleep"/)
      (5..15).should cover(queue.length)
    end
  end
end
