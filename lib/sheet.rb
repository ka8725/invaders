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
          unless allowed_point?(char)
            raise ArgumentError, "not allowed char for #{entity_type}: #{char}"
          end
        end
      end
    end

    def allowed_point?(char)
      self.class.allowed_points.include?(char)
    end
  end

  class InvaderBuilder < BaseBuilder
    self.entity_type = :invader

  end

  class SampleBuilder < BaseBuilder
    self.entity_type = :sample
  end

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

  # Returns a char for the given Point(row, column) with zero-based indexes.
  #
  # @param point [Point]
  #
  # @return [Char]
  # @raise [ArgumentError] for an index outbound
  def at(point)
    row, column = point.row, point.column
    if row >= height || column >= width
      raise ArgumentError, "outbound indexes (#{row}, #{column}) for the sheet (#{height}x#{width})"
    end
    lines[row][column]
  end

  def each_point
    Enumerator.new do |yielder|
      (0..height.pred).each do |row|
        (0..width.pred).each do |column|
          yielder << Point.new(row: row, column: column)
        end
      end
    end
  end

  def ==(other)
    lines == other.lines && width == other.width && height == other.height
  end
end
