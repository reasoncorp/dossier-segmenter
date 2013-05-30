require 'spec_helper'

describe Dossier::Segmenter::Report do
  let(:report_class)    { Class.new(Dossier::Report) }
  let(:segmenter_class) { report_class.const_get(:Segmenter) }

  it "creates a segment subclass under its own namespace when inherited" do
    expect(segmenter_class.ancestors).to include(Dossier::Segmenter)
  end

  it "sets its class on the created segment_class" do
    expect(segmenter_class.report_class).to eq report_class
  end

  it "has a reference to its segmenter class" do
    expect(TestReport.segmenter_class).to eq TestReport::Segmenter
  end

  it "does not have a segmenter if no segments have been defined" do
    expect(report).to_not be_segmented
    expect(report.segmenter).to be_nil
  end
end
