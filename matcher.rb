# frozen_string_literal: true

require_relative './config'
require_relative './sheet'
require_relative './point'

class Matcher
  def initialize(app_config)
    @app_config = app_config
  end

  # @param sample [Sheet]
  # @return [Set<Point>]
  def matched_invaders(sample)
    app_config.invaders.each_with_object([]) do |invader, result|
      max_x = sample.height - invader.height
      max_y = sample.width - invader.width
      (0..max_x).each do |x|
        (0..max_y).each do |y|
          point = Point.new(x: x, y: y)
          result << point if invader_matches?(sample, point, invader)
        end
      end
    end
  end

  private

  attr_reader :app_config

  def invader_matches?(sample, point, invader)
    noise = 0
    (0..invader.height.pred).each do |x|
      (0..invader.width.pred).each do |y|
        xx = x + point.x
        yy = y + point.y
        noise += 1 if sample.lines[xx][yy] != invader.lines[x][y]
        return false if noise > app_config.noise_threshold
      end
    end
    true
  end
end
