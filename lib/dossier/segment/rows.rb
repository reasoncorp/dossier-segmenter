module Dossier
  class Segment
    class Rows < Dossier::Result::Formatted
      attr_accessor :segmenter, :segment, :report, :definition

      def initialize(segmenter, segment, definition)
        self.segmenter  = segmenter
        self.report     = segmenter.report
        self.segment    = segment
        self.definition = definition
      end

      delegate :headers, to: :segmenter
      delegate :length, :count, :empty?, to: :rows

      def each
        segmenter_data.each { |row| yield format(summarize(truncate(row))) }
      end

      def inspect
        "#<#{self.class.name}:@rows.count=#{rows.count}>"
      end

      private

      def segmenter_data
        @segmenter_data ||= segmenter.data.fetch(segment.key_path)
      end

      def truncate(row)
        row.tap { |r| segmenter.header_index_map.values.sort.each_with_index { |i, j| r.delete_at(i - j) } }
      end

      def summarize(row)
        row.tap { |r| segment.chain.each { |s| s.summarize row } }
      end
    end
  end
end
