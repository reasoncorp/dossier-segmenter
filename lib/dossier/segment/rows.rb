module Dossier
  class Segment
    class Rows
      include Enumerable

      attr_accessor :segmenter, :segment, :report, :definition

      def initialize(segmenter, segment, definition)
        self.segmenter  = segmenter
        self.report     = segmenter.report
        self.segment    = segment
        self.definition = definition
      end

      def each
        rows.each { |row| yield summarize(format(row)) }
      end

      delegate :length, :count, :empty?, to: :rows

      def inspect
        "#<#{self.class.name}:@rows.count=#{rows.count}>"
      end

      private

      def rows
        @rows ||= segmenter.data.fetch(segment.key_path)
      end

      def format(row)
        row.tap { |r| segmenter.header_index_map.values.sort.each_with_index { |i, j| r.delete_at(i - j) } }
      end

      def summarize(row)
        row.tap { |r| segment.chain.each { |s| s.summarize row } }
      end
    end
  end
end
