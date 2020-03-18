require_relative './config'
require_relative './sheet'
require_relative './point'

# Entry point of the application.
#
# @example
#   app = App.new(invaders: ["--\--"], noise_threshold: 1)
#   app.find_invaders("--\-O") => [Point.new(x: 0, y: 0)]
class App
  # Incapsulates the matching functionality.
  class Matcher
    # @param app_config [Config]
    def initialize(app_config)
      @app_config = app_config
    end

    # @param sample [Sheet]
    # @return [Array<Point>]
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

  def initialize(invaders:, noise_threshold: 0)
    @config = Config.configure do |config|
      config.invaders = build_invaders_sheets(invaders, config)
      config.noise_threshold = noise_threshold
    end
  end

  # @param sample [String] a joined string of the sample
  # @return [Array<Point>] left top corners of the found invaders for the given sample
  # @raise [StandardError] @see Sheet.build for more details
  def find_invaders(sample)
    sample = Sheet.build(:sample, sample, config)
    Matcher.new(config).matched_invaders(sample)
  end

  private

  attr_reader :config

  def build_invaders_sheets(invaders, app_config)
    invaders.compact.map { |invader| Sheet.build(:invader, invader, app_config) }
  end
end
