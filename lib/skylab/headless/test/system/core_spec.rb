require_relative 'test-support'

module Skylab::Headless::TestSupport::System

  describe "[hl] system (front)" do

    extend TS_

    it "loads" do
      subject
    end

    it "reflects members #fragile" do
      subject.members.should eql [ :defaults, :diff, :environment, :filesystem, :IO, :patch, :which ]
    end
  end
end
