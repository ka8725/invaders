# frozen_string_literal: true

class Radar
  ALLOWED_POINTS = ['o', '-'].freeze
  NOISE = 'O'

  Point = Struct.new(:x, :y, keyword_init: true)
  Invader = Struct.new(:lines, :width, :height, keyword_init: true)
  Sample = Struct.new(:lines, :width, :height, keyword_init: true)

  attr_accessor :invaders

  # @param invaders [Array<String>]
  def initialize(invaders)
    @invaders = invaders.compact.map { |invader| Invader.new(extract_display_data(invader)) }
  end

  # @param sample [String]
  # @return [Set<Point>]
  def find_invaders(sample, allowed_noise: 0)
    return Set.new if sample.nil?
    sample_display = Sample.new(extract_display_data(sample, sample: true))
    matched_invaders(invaders, sample_display, allowed_noise: allowed_noise)
  end

  private

  def matched_invaders(invaders, sample_display, allowed_noise:)
    invaders.each_with_object(Set.new) do |invader, result|
      max_x = sample_display.height - invader.height
      max_y = sample_display.width - invader.width
      (0..max_x).each do |x|
        (0..max_y).each do |y|
          point = Point.new(x: x, y: y)
          result.add(point) if invader_matches?(sample_display, point, invader, allowed_noise: allowed_noise)
        end
      end
    end
  end

  def invader_matches?(sample_display, point, invader, allowed_noise:)
    noise = 0
    (0..invader.height.pred).each do |x|
      (0..invader.width.pred).each do |y|
        xx = x + point.x
        yy = y + point.y
        noise += 1 if sample_display.lines[xx][yy] != invader.lines[x][y]
        return false if noise > allowed_noise
      end
    end
    true
  end

  def extract_display_data(joined_line, sample: false)
    lines = split_lines(joined_line, sample: sample)
    {lines: lines, width: lines.first&.size || 0, height: lines.size}
  end

  def split_lines(joined_line, sample:)
    joined_line.split.tap do |res|
      assert_allowed_points!(res, sample: sample)
      assert_rectangle!(res)
    end
  end

  def assert_rectangle!(res)
    raise ArgumentError, "sample or invader must be rectangular" if res.map(&:size).uniq.size > 1
  end

  def assert_allowed_points!(lines, sample:)
    allowed_points = sample ? ALLOWED_POINTS + [NOISE] : ALLOWED_POINTS
    lines.each do |line|
      line.each_char do |char|
        raise ArgumentError, "not allowed char: #{char}" unless allowed_points.include?(char)
      end
    end
  end
end
