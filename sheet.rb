class Sheet
  class BaseBuilder
    class << self
      attr_writer :entity_type

      def entity_type
        @entity_type || raise('entity type is not specified, use self.entity_type=')
      end

      def build_sheet(joined_string, app_config)
        self.new(app_config).build_sheet(joined_string)
      end
    end

    def initialize(app_config)
      @entity_type = self.class.entity_type
      @app_config = app_config
    end

    def build_sheet(joined_string)
      lines = split_lines(joined_string)
      Sheet.new(lines: lines, width: lines.first&.size || 0, height: lines.size)
    end

    private

    attr_reader :entity_type, :app_config

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
          raise ArgumentError, "not allowed char for #{entity_type}: #{char}" unless allowed_points.include?(char)
        end
      end
    end

    def allowed_points
      app_config.allowed_points.fetch(entity_type)
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
  # @param entity_type [Symbol] known entities are speficied in the Sheet::BUILDER constant
  # @param joined_string [String] a string joined with \n
  # @param app_config [Config] the application configuration
  # @return [Sheet]
  # @raise [KeyError] for unknown entity type
  # @raise [ArgumentError] if the joined string does not pass the validation rules, @see BaseBuilder
  def self.build(entity_type, joined_string, app_config)
    BUILDERS.fetch(entity_type).build_sheet(joined_string, app_config)
  end

  def ==(other)
    lines == other.lines && width == other.width && height == other.height
  end
end
