module Dossier
  class Segmenter
    module Summable

      def summarize(row)
        row.tap { summary << row }
      end

      def summary
        @summary ||= Dossier::Segment::Summary.new(headers)
      end

    end
  end
end
