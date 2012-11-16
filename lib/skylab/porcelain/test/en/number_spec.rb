require_relative 'test-support'

describe "#{::Skylab::Porcelain::En::Number}", ok:true do
  include ::Skylab::Porcelain::En::Number::Methods
  def self.does mixed, str
    let( :subject ) { send meth, mixed }
    it("#{mixed} becomes #{str.inspect}") { subject.should eql(str) }
  end
  context "number" do
    let( :meth ) { :number }
    does 42388, 'forty two thousand three hundred eighty eight'
  end
  context "num2ord" do
    let( :meth ) { :num2ord }
    does 42388, 'forty two thousand three hundred eighty eighth'
  end
end
