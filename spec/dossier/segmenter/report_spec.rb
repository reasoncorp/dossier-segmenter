require 'spec_helper'

describe Dossier::Segmenter::Report do

  it "has a reference to its segmenter class" do
    expect(CuteAnimalsReport.segmenter_class).to eq CuteAnimalsReport::Segmenter
  end

end
