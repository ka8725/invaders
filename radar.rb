class Radar
  ALLOWED_POINTS = ['0', '-'].freeze

  Point = Struct.new(:x, :y, keyword_init: true)
  Invader = Struct.new(:lines, :width, :height, keyword_init: true)
  Sample = Struct.new(:lines, :width, :height, keyword_init: true)

  attr_accessor :invaders

  # @param invaders [Array<String>]
  def initialize(invaders)
    @invaders = invaders.compact.map { |invader| Invader.new(extract_display_data(invader)) }
  end

  # @param sample [String]
  # @return [Array<Point>]
  def find_invaders(sample)
    return [] if sample.nil?
    sample_display = Sample.new(extract_display_data(sample))
    invaders.each_with_object([]) do |invader, result|
      max_left_top = sample_display.width - invader.width
      max_left_bottom = sample_display.height - invader.height
      (0..max_left_top).each do |x|
        (0..max_left_bottom).each do |y|
          point = Point.new(x: x, y: y)
          result << point if invader_matches?(sample_display, point, invader) # TODO: move to a separate class?
        end
      end
    end
  end

  private

  def invader_matches?(sample_display, point, invader, allowed_noise = 0) # TODO: configure allowed noise through injection
    noise = 0
    (0..invader.width).each do |x|
      (0..invader.height).each do |y|
        xx = x + point.x
        yy = y + point.y
        noise += 1 if sample_display[xx][yy] != invader[x][y]
        return false if noise > allowed_noise
      end
    end
    true
  end

  def extract_display_data(joined_line)
    lines = split_lines(joined_line)
    {lines: lines, width: lines.first&.size || 0, height: lines.size}
  end

  def split_lines(joined_line)
    joined_line.split.tap { |res| validate_lines_points!(res) }
  end

  def validate_lines_points!(lines)
    lines.each(&method(:validate_line_points!))
  end

  def validate_line_points!(line)
    line.each_char do |char|
      raise ArgumentError, "not allowed char: #{char}" unless ALLOWED_POINTS.include?(char)
    end
  end
end
