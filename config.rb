require 'singleton'

class Config
  attr_accessor :invaders, :noise_threshold, :sheet_builders

  def initialize
    @invaders = []
    @noise_threshold = 0
    @sheet_builders = {}
    register_sheet_builder(:invader, ['o', '-'], Sheet::InvaderBuilder)
    register_sheet_builder(:sample, ['o', '-', 'O'], Sheet::SampleBuilder)
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
