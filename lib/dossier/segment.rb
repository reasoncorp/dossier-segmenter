module Dossier
  class Segment
    attr_accessor :segmenter, :report, :definition, :parent, :options

    def initialize(segmenter, definition, options = {})
      self.segmenter  = segmenter
      self.report     = segmenter.report
      self.definition = definition
      self.options    = options.symbolize_keys
      extend(definition.chain_module)
    end

    def display_name
      if definition.display_name.respond_to?(:call)
        definition.display_name.call(options)
      else
        options.fetch(definition.display_name)
      end
    end
    
    def group_by
      options.fetch(definition.group_by)
    end

    def chain
      @chain ||= [].tap { |collector| parent_chain(self, collector) }
    end

    def key_path
      chain.map(&:group_by).reverse.join('.')
    end

    def inspect
      "#<#{self.class.name}:#{key_path}>"
    end

    def summarize(row)
      summary << row
    end

    def summary
      @summary ||= Summary.new(headers)
    end

    delegate :headers, to: :segmenter

    private

    def parent_chain(segment, collector)
      collector << segment
      parent_chain(segment.parent, collector) if segment.parent
    end
  end
end
