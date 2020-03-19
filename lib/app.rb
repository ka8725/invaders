require_relative './config'
require_relative './sheet'
require_relative './point'

# Entry point of the application.
#
# @example
#   app = App.new(invaders: ["--\--"], mismatch_threshold: 1)
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
        max_row = sample.height - invader.height
        max_column = sample.width - invader.width
        (0..max_row).each do |row|
          (0..max_column).each do |column|
            point = Point.new(row: row, column: column)
            result << point if invader_matches?(sample, point, invader)
          end
        end
      end
    end

    private

    attr_reader :app_config

    def invader_matches?(sample, start_point, invader)
      mismatches = 0
      (0..invader.height.pred).each do |invader_row|
        (0..invader.width.pred).each do |invader_column|
          sample_row = invader_row + start_point.row
          sample_column = invader_column + start_point.column
          mismatches += 1 if sample.at(sample_row, sample_column) != invader.at(invader_row, invader_column)
          return false if mismatches > app_config.mismatch_threshold
        end
      end
      true
    end
  end

  def initialize(invaders:, mismatch_threshold: 0)
    @config = Config.configure do |config|
      config.invaders = build_invaders_sheets(invaders, config)
      config.mismatch_threshold = mismatch_threshold
    end
  end

  private_constant :Matcher

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
