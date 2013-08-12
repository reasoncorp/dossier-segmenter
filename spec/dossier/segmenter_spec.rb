require 'spec_helper'

describe Dossier::Segmenter do

  let(:report_class)    { Class.new(Dossier::Report) }
  let!(:segmenter_class) {
    report_class.const_set(:Segmenter, Class.new(described_class) {
        segment :family
        segment :domestic, display_name: ->(row) { "#{row[:domestic] ? 'Domestic' : 'Wild'} #{row[:group_name]}" } do
          segment :group,  display_name: :group_name, group_by: :group_id
        end
    })
  }
  let(:headers)   { CuteAnimalsReport::HEADERS.call }
  let(:rows)      { CuteAnimalsReport::ROWS.call    }
  let(:results)   { double('Results', headers: headers, rows: rows) }
  let(:report)    { report_class.new.tap { |r| r.stub(:raw_results).and_return(results) } }
  let(:segmenter) { report.segmenter }

  describe "report data" do
    let(:data) {
      {
        'canine.true.10' => [
          ['canine', true,  10, 'foxes', 'fennec',      'tan',    9, 896, true, 1_000],
          ['canine', true,  10, 'foxes', 'fire',        'orange', 0, 468, false, 0],
        ],
        'canine.false.10' => [
          ['canine', false, 10, 'foxes', 'arctic',      'white',  5, 108, false, 2_500],
          ['canine', false, 10, 'foxes', 'crab-eating', 'brown',  3, 328, false, 5_000],
          ['canine', false, 10, 'foxes', 'red',         'orange', 5, 963, false, 750],
        ],
        'canine.true.15' => [
          ['canine', true,  15, 'dog',   'shiba inu',   'tan',    7, 191, true, 200],
          ['canine', true,  15, 'dog',   'labrador',    'varied', 5, 269, true, 50],
          ['canine', true,  15, 'dog',   'beagle',      'mixed',  8, 917, true, 25],
          ['canine', true,  15, 'dog',   'boxer',       'brown',  5, 14,  true, 50],
        ],
        'feline.false.22' => [
          ['feline', false, 22, 'tiger', 'bengal',      'orange', 4, 184, false, 100_000],
          ['feline', false, 22, 'tiger', 'siberian',    'white',  5, 970, false, 500_000],
        ],
        'feline.false.23' => [
          ['feline', false, 23, 'lion',  'lion',        'tan',    5, 128, false, 100_000],
        ],
        'feline.true.219' => [
          ['feline', true,  219, 'cat',  'short hair',  'varied', 6, 2062, true, 10],
          ['feline', true,  219, 'cat',  'abyssinian',  'tan',    7, 125,  true, 20],
          ['feline', true,  219, 'cat',  'persian',     'varied', 6, 625,  false, 50],
          ['feline', true,  219, 'cat',  'wirehair',    'grey',   7, 758,  true, 75],
        ]
      }
    }

    it "stores the report rows in a hash organized by segment" do
      expect(segmenter.data).to eq(data)
    end
  end

  describe "instances" do
    it "takes a report upon instantiation" do
      expect(segmenter.report).to eq report
    end

    it "has access to the class segment chain" do
      expect(segmenter.segment_chain.length).to eq 3
    end
  end

  describe "class" do
    it "determines headers to skip when displaying" do
      expect(segmenter_class.skip_headers.sort).to eq %w[family group_name group_id domestic].sort
    end
  end

  describe "DSL" do
    describe "segment" do
      describe "definition creation" do
        let(:segmenter_class) { report_class.const_set(:Segmenter, Class.new(described_class)) }
        let(:definition)      { segmenter_class.segments.last }

        it "creates a segment definition" do
          segmenter_class.segment :foo
          expect(definition).to be_a Dossier::Segment::Definition
        end

        it "passes the name option" do
          segmenter_class.segment :foo
          expect(definition.name).to eq :foo
        end

        it "passes the group_by option"  do
          segmenter_class.segment :name, group_by: :foo
          expect(definition.group_by).to eq :foo
        end

        it "passes the display_name option" do
          segmenter_class.segment :name, display_name: :foo
          expect(definition.display_name).to eq :foo
        end
      end

      it "keeps an array of segments" do
        expect(segmenter_class.segments.count).to eq 3
      end

      it "keeps the segments in the order defined" do
        expect(segmenter_class.segments[0].name).to eq :family
        expect(segmenter_class.segments[1].name).to eq :domestic
      end

      it "allows nesting segment definations" do
        expect(segmenter_class.segments[2].name).to eq :group
      end
    end
  end

  describe "segment options" do
    it 'works the way I want it to' do
      segment = double('Segment', key_path: 'feline.false')
      options = segmenter.segment_options_for segment
      expect(options.map { |hash| hash['group_id'] }).to eq [22, 23]
    end
  end

  describe "segment traversal" do

    describe "from the segmenter to the first segment" do
      it "has an array of families" do
        expect(report.segmenter.families.length).to eq 2
      end

      describe "to the second segment" do
        let(:family) { report.segmenter.families.first }

        it "has an array of domestics" do
          expect(family.domestics.length).to eq 2
        end

        describe "to the third segment" do
          let(:domestic) { family.domestics.first }

          it "has an array of groups" do
            expect(domestic.groups.length).to eq 2
          end

          describe "to the rows" do
            let(:group) { domestic.groups.first }

            it "has rows" do
              expect(group.rows.length).to eq 2
            end

            describe "to additional rows" do
              let(:group) { domestic.groups.last }

              it "has rows" do
                expect(group.rows.length).to eq 4
              end
            end
          end
        end
      end
    end
  end


  describe "summarizing" do
    before(:each) { 
      # run through all of the rows, triggering each, which calls summarize
      segmenter.families.map(&:domestics).flatten.map(&:groups).flatten.map(&:rows).flatten.map(&:to_a)
    }

    it "properly sums all rows for the entire report" do
      expect(segmenter.summary.sum(:gifs).to_s).to eq '9006.0'
    end
  end
end
