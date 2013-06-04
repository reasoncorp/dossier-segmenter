require 'spec_helper'

describe "segmented report" do
  let(:path) { dossier_report_path(report: 'cute_animals') }

  before(:each) { visit path }
  
  it "displays the correct html" do
    expect(page).to have_content('canine')
    expect(page).to have_content('shiba inu')
  end

  it "does not display options that are only used for grouping" do
    expect(page).to_not have_content('219') # group_ids
  end

  it "displays its options" do
    pending "support options"
    expect(page).to have_content('Some options plz!')
  end

  it "has summaries" do
    expect(page).to have_content '$300,000.00'
    expect(page).to have_content '3,570.0'
  end

end

