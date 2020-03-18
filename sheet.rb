class Sheet
  class BaseBuilder
    class << self
      attr_writer :entity_type
      attr_reader :allowed_points

      def entity_type
        @entity_type || raise('entity type is not specified, use self.entity_type=')
      end

      def build_sheet(joined_string)
        self.new.build_sheet(joined_string)
      end

      def with(allowed_points)
        @allowed_points = allowed_points
        self
      end
    end

    def initialize
      @entity_type = self.class.entity_type
    end

    def build_sheet(joined_string)
      lines = split_lines(joined_string || '')
      Sheet.new(lines: lines, width: lines.first&.size || 0, height: lines.size)
    end

    private

    attr_reader :entity_type

    def split_lines(joined_string)
      joined_string.split.tap do |lines|
        assert_allowed_points!(lines)
        assert_rectangle!(lines)
      end
    end

    def assert_rectangle!(lines)
      raise ArgumentError, "#{entity_type} must be rectangular" if lines.map(&:size).uniq.size > 1
    end

    def assert_allowed_points!(lines)
      lines.each do |line|
        line.each_char do |char|
          unless allowed_points.include?(char)
            raise ArgumentError, "not allowed char for #{entity_type}: #{char}"
          end
        end
      end
    end

    def allowed_points
      self.class.allowed_points
    end
  end

  class InvaderBuilder < BaseBuilder
    self.entity_type = :invader

  end

  class SampleBuilder < BaseBuilder
    self.entity_type = :sample
  end

  BUILDERS = {
    invader: InvaderBuilder,
    sample: SampleBuilder
  }

  attr_reader :lines, :width, :height

  def initialize(lines:, width:, height:)
    @lines = lines
    @width = width
    @height = height
  end

  # A factory method that instantiates a sheet for the given entity type and the joined string.
  # @param entity_type [Symbol] known registered entity type, @see Config
  # @param joined_string [String] a string joined with \n that will be used for a Sheet instantiating
  # @param app_config [Config] the application configuration
  # @return [Sheet]
  # @raise [KeyError] for unknown entity type
  # @raise [ArgumentError] if the joined string does not pass the validation rules, @see BaseBuilder
  def self.build(entity_type, joined_string, app_config)
    app_config.sheet_builders.fetch(entity_type).build_sheet(joined_string)
  end

  def ==(other)
    lines == other.lines && width == other.width && height == other.height
  end
end
