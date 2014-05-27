require 'spec_helper'

describe Dossier::Segment do
  let(:report_class)     { Class.new(Dossier::Report) }
  let!(:segmenter_class) { 
    report_class.const_set(:Segmenter, Class.new(Dossier::Segmenter) { |sc|
      sc.segment :foo
    })
  }
  let(:definition)      { segmenter_class.segments.first }
  let(:report)          { report_class.new }
  let(:segmenter)       { report.segmenter }
  let(:segment)         { described_class.new(segmenter, definition) }

  describe "attributes" do
    it "takes the segment instance" do
      expect(segment.segmenter).to eq segmenter
    end

    it "takes its definition" do
      expect(segment.definition).to eq definition
    end

    it "has access to the report" do
      expect(segment.report).to eq report
    end

    it "delegates headers to its segmenter" do
      segment.segmenter.should_receive(:headers)
      segment.headers
    end
  end


  describe CuteAnimalsReport do
    describe "key paths" do
      let(:report)     { CuteAnimalsReport.new }
      let!(:segmenter) { report.segmenter }
      let(:families)   { segmenter.families }
      let(:domestics)  { families.map(&:domestics).flatten }
      let(:groups)     { domestics.map(&:groups).flatten }
      let(:rows)       { groups.inject([]) { |a,g| a += g.rows.to_a } } 

      describe "select the correct amount of segments" do

        it "has the right amount of families" do
          expect(families.count).to eq 2
        end

        it "has the right amount of domestics" do
          expect(domestics.count).to eq 4
        end

        it "has the right amount of groups" do
          expect(groups.count).to eq 6
        end

        it "has the right amount of rows" do
          expect(rows.count).to eq CuteAnimalsReport::ROWS.call.count
        end
      end

      describe "summarizing" do
        before(:each) { rows }

        it "properly sums all rows under family" do
          expect(families.first.summary.sum(:gifs).to_s).to eq '4154.0'
        end

        it "properly sums all rows under domestic" do
          expect(domestics.first.summary.sum(:gifs).to_s).to eq '2755.0'
        end

        it "property sums all the rows under group" do
          expect(groups.first.summary.sum(:gifs).to_s).to eq '1364.0'
        end

        describe "segment chains" do
          let(:family_definition)    { segmenter.segment_chain[0] }
          let(:domestic_definition)  { segmenter.segment_chain[1] }
          let(:group_definition)     { segmenter.segment_chain[2] }
          let(:family)   { described_class.new(segmenter, family_definition,   {family: 'feline'}) }
          let(:domestic) { described_class.new(segmenter, domestic_definition, {domestic: true}  ).tap { |s| s.parent = family   } }
          let(:group)    { described_class.new(segmenter, group_definition,    {group_id: 25}    ).tap { |s| s.parent = domestic } }

          it "has all three elements in the chain from the bottom" do
            expect(group.chain).to eq [group, domestic, family]
          end

          it "has two elements in the chain from the middle" do
            expect(domestic.chain).to eq [domestic, family]
          end

          it "has one element in the chain from the top" do
            expect(family.chain).to eq [family]
          end

          it "does not replicate elements in the chain when accessed again" do
            family.chain
            expect(family.chain.length).to eq 1
          end

          describe "key paths" do
            it "works from the bottom" do
              expect(group.key_path).to eq 'feline.true.25'
            end

            it "works from the middle" do
              expect(domestic.key_path).to eq 'feline.true'
            end

            it "works from the top" do
              expect(family.key_path).to eq 'feline'
            end
          end
        end
      end
    end
  end
end
