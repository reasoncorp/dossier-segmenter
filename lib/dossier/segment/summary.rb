module Dossier
  class Segment
    class Summary

      attr_reader :count, :average, :sum

      def initialize(headers)
        @headers = headers.map(&:to_s)
        @count   = 0
        @sums    = headers.map { 0 }
      end

      def <<(row)
        @count += 1
        row.each_with_index { |v, i| sums[i] += BigDecimal.new(v.to_s) }
        self
      end

      def sum(key)
        sums.at(index_of key)
      end

      def average(key)
        sum(key) / count
      end

      private

      attr_reader :headers, :sums

      def index_of(key)
        key = key.to_s
        @indexes ||= {}
        @indexes[key] ||= headers.index(key)
      end
    end
  end
end
