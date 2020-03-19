class Config
  attr_accessor :invaders, :noise_threshold, :sheet_builders

  class Wildcard < String
    def include?(char)
      true
    end
  end

  private_constant :Wildcard

  def initialize
    @invaders = []
    @noise_threshold = 0
    @sheet_builders = {}
    register_sheet_builder(:invader, 'o-', Sheet::InvaderBuilder)
    register_sheet_builder(:sample, Wildcard.new, Sheet::SampleBuilder)
  end

  def self.configure
    instance = new
    yield instance
    instance
  end

  private

  def register_sheet_builder(entity_type, allowed_points, builder)
    sheet_builders[entity_type] = builder.with(allowed_points)
  end
end
