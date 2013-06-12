module Dossier
  class Segmenter
    module Report
      extend ActiveSupport::Concern

      def segment_parent
        nil
      end

      def segmenter
        @segmenter ||= self.class.segmenter_class.new(self)
      end

      def segmented?
        self.class.segmenter_class.segments.any?
      end

      module ClassMethods
        def segmenter_class
          const_get(:Segmenter)
        end
      end

      Dossier::Report.send :include, self
    end
  end
end
