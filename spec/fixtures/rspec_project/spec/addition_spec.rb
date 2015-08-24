require 'spec_helper.rb'

describe Addition do
  it "adds two numbers" do
    a = Addition.new
    result = a.call(3, 3)
    expect(result).to eq 6
  end
end
