# frozen_string_literal: true

class Radar
  INVADER_POINTS = ['o', '-'].freeze
  NOISE = 'O'

  Point = Struct.new(:x, :y, keyword_init: true)
  Sheet = Struct.new(:lines, :width, :height, keyword_init: true)

  attr_accessor :invaders, :sample

  # @option invaders [Array<String>]
  # @option sample [String|nil] if nil, sets an empty sheet
  def initialize(invaders:, sample:)
    @invaders = invaders.compact.map { |invader| Sheet.new(extract_sheet(:invader, invader)) }
    @sample = Sheet.new(extract_sheet(:sample, sample || ''))
  end

  # @option noise_threshold [Integer]
  # @return [Set<Point>]
  def find_invaders(noise_threshold: 0)
    matched_invaders(invaders, sample, noise_threshold: noise_threshold)
  end

  private

  def matched_invaders(invaders, sample_display, noise_threshold:)
    invaders.each_with_object(Set.new) do |invader, result|
      max_x = sample_display.height - invader.height
      max_y = sample_display.width - invader.width
      (0..max_x).each do |x|
        (0..max_y).each do |y|
          point = Point.new(x: x, y: y)
          result.add(point) if invader_matches?(sample_display, point, invader, noise_threshold: noise_threshold)
        end
      end
    end
  end

  def invader_matches?(sample_display, point, invader, noise_threshold:)
    noise = 0
    (0..invader.height.pred).each do |x|
      (0..invader.width.pred).each do |y|
        xx = x + point.x
        yy = y + point.y
        noise += 1 if sample_display.lines[xx][yy] != invader.lines[x][y]
        return false if noise > noise_threshold
      end
    end
    true
  end

  # @param entity_type [Symbol] :invader or :sample
  def extract_sheet(entity_type, joined_line)
    lines = split_lines(entity_type, joined_line)
    {lines: lines, width: lines.first&.size || 0, height: lines.size}
  end

  def split_lines(entity_type, joined_line)
    joined_line.split.tap do |lines|
      assert_allowed_points!(entity_type, lines)
      assert_rectangle!(entity_type, lines)
    end
  end

  def assert_rectangle!(entity_type, lines)
    raise ArgumentError, "#{entity_type} must be rectangular" if lines.map(&:size).uniq.size > 1
  end

  def assert_allowed_points!(entity_type, lines)
    allowed_points = entity_type == :sample ? INVADER_POINTS + [NOISE] : INVADER_POINTS
    lines.each do |line|
      line.each_char do |char|
        raise ArgumentError, "not allowed char for #{entity_type}: #{char}" unless allowed_points.include?(char)
      end
    end
  end
end
