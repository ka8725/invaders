RSpec.describe App do
  let(:app) do
    if defined?(mismatch_threshold)
      described_class.new(invaders: invaders, mismatch_threshold: mismatch_threshold)
    else
      described_class.new(invaders: invaders)
    end
  end

  let(:invaders) { ["--\noo"] }
  let(:sample) { "--\noo" }

  def match(row, column, invader, penalty)
    Match.new(point: Point.new(row: row, column: column), invader: invader, match_penalty: penalty)
  end

  describe '#find_invaders' do
    subject { app.find_invaders(sample) }

    context 'when invader 100% matches' do
      let(:sample) { "--\noo" }
      it { is_expected.to eq([match(0, 0, 0, 0)]) }
    end

    context 'when sample does not have invaders' do
      context 'with empty sample' do
        let(:sample) { '' }
        it { is_expected.to eq([]) }
      end

      context 'with unmatched sample' do
        let(:sample) { "oo\noo" }
        it { is_expected.to eq([]) }
      end

      context 'with sample smaller than invaders' do
        let(:sample) { '-' }
        it { is_expected.to eq([]) }
      end
    end

    context 'when invader has many matches' do
      let(:sample) { "---\n---\n---" }
      let(:invaders) { ["--\n--", "---\n---"] }
      it {
        is_expected.to eq(
          [
            match(0, 0, 0, 0),
            match(0, 1, 0, 0),
            match(1, 0, 0, 0),
            match(1, 1, 0, 0),
            match(0, 0, 1, 0),
            match(1, 0, 1, 0)
          ]
        )
      }
    end

    context 'with partial matches' do
      let(:sample) { "---\n---\n--x" }
      let(:invaders) { ["---\n---\n---"] }

      it { is_expected.to eq([]) }

      context 'with increased threshhold to 0.5' do
        let(:mismatch_threshold) { 0.5 }
        it { is_expected.to eq([match(0, 0, 0, 0.5)]) }

        context 'without noise' do
          let(:sample) { "---\n---\n--o" }
          it { is_expected.to eq([]) }
        end
      end

      context 'with increased threshhold to 1' do
        let(:mismatch_threshold) { 1 }
        it { is_expected.to eq([match(0, 0, 0, 0.5)]) }

        context 'without noise' do
          let(:sample) { "---\n---\n--o" }
          it { is_expected.to eq([match(0, 0, 0, 1)]) }
        end
      end
    end

    context 'with real invaders and sample' do
      let(:sample) { File.read("#{__dir__}/fixtures/sample.txt") }
      let(:invaders) { File.read("#{__dir__}/fixtures/invaders.txt").split('~') }

      it { is_expected.to eq([]) }

      context 'when increased noise threshold' do
        let(:mismatch_threshold) { 8 }
        it { is_expected.to eq([match(13, 60, 0, 8), match(0, 42, 1, 8)]) }
      end
    end
  end
end
