require 'spec_helper'

describe Dossier::Segment::Summary do

  let(:summary) { described_class.new(headers) }
  let(:headers) { %w[animal weight cuteness fanciness] }
  let(:rows)    { [
    ['Cats', 15.0, 97, true],
    ['Dogs', 88.2, 45, false] # dogs aren't very fancy animals...
  ] }
  
  before(:each) {
    rows.each { |row| summary << row }
  }

  it "counts all the objects it has summarized" do
    expect(summary.count).to eq 2
  end

  it "allows appending multiple rows" do
    summary << rows[0] << rows[1]
    expect(summary.count).to eq 4
  end

  describe "summing" do
    it "handles whole numbers" do
      expect(summary.sum :cuteness).to eq 142
    end

    it "handles decimal places" do
      expect(summary.sum :weight).to eq 103.2
    end
  end

  describe "averaging" do
    it "handles whole numbers" do
      expect(summary.average :cuteness).to eq 71
    end

    it "handles decimal places" do
      expect(summary.average :weight).to eq 51.6
    end
  end

end
