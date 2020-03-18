# TODO: edge case invader greater than sample
RSpec.describe Radar do
  subject(:radar) { described_class.new(invaders: invaders, sample: sample) }

  let(:invaders) { ["--\noo"] }
  let(:sample) { "--\noo" }

  def point(x, y)
    described_class::Point.new(x: x, y: y)
  end

  def sheet(lines)
    described_class::Sheet.new(lines: lines, width: lines.first&.size || 0, height: lines.size)
  end

  describe '#initialize' do
    describe 'invaders:' do
      subject { radar.invaders }

      context 'when some invaders are nil' do
        let(:invaders) { [nil, 'o'] }
        it { is_expected.to eq([sheet(['o'])]) }
      end

      context 'when is a multiline' do
        let(:invaders) { ["o\n-"] }
        it { is_expected.to eq([sheet(['o', '-'])]) }
      end

      context 'when has invalid points' do
        let(:invaders) { ['x'] }
        specify { expect { subject }.to raise_error(ArgumentError, 'not allowed char for invader: x') }
      end

      context 'when has noise points' do
        let(:invaders) { ['O'] }
        specify { expect { subject }.to raise_error(ArgumentError, 'not allowed char for invader: O') }
      end

      context 'when is not rectangular' do
        let(:invaders) { ["-\n--"] }
        specify { expect { subject }.to raise_error(ArgumentError, 'invader must be rectangular') }
      end
    end

    describe 'sample:' do
      subject { radar.sample }

      context 'when is nil' do
        let(:sample) { nil }
        it { is_expected.to eq(sheet([])) }
      end

      context 'when is a multiline' do
        let(:sample) { "o\n-" }
        it { is_expected.to eq(sheet(['o', '-'])) }
      end

      context 'when has noise' do
        let(:sample) { "o\nO" }
        it { is_expected.to eq(sheet(['o', 'O'])) }
      end

      context 'when has invalid points' do
        let(:sample) { 'x' }
        specify { expect { subject }.to raise_error(ArgumentError, 'not allowed char for sample: x') }
      end

      context 'when is not rectangular' do
        let(:sample) { "-\n--" }
        specify { expect { subject }.to raise_error(ArgumentError, 'sample must be rectangular') }
      end
    end
  end

  describe '#find_invaders' do
    subject { radar.find_invaders }

    context 'when sample is empty string' do
      let(:sample) { '' }
      it { is_expected.to eq([].to_set) }
    end

    context 'when sample is nil' do
      let(:sample) { nil }
      it { is_expected.to eq([].to_set) }
    end

    context 'when sample is "\n"' do
      let(:sample) { "\n" }
      it { is_expected.to eq([].to_set) }
    end

    context 'when sample has invaders' do
      let(:sample) { "--\noo" }

      it 'returns invaders coordinates' do
        expect(subject).to eq([point(0, 0)].to_set)
      end
    end

    context 'when sample does not have invaders' do
      context 'with empty sample' do
        let(:sample) { '' }
        it { is_expected.to eq([].to_set) }
      end

      context 'with unmatched sample' do
        let(:sample) { "oo\noo" }
        it { is_expected.to eq([].to_set) }
      end
    end

    context 'with real invaders and sample' do
      let(:sample) { File.read("#{__dir__}/fixtures/sample.txt") }
      let(:invaders) { File.read("#{__dir__}/fixtures/invaders.txt").split('~') }

      it { is_expected.to eq([].to_set) }

      context 'when increased allowed noise' do
        subject { radar.find_invaders(noise_threshold: 8) }

        it { is_expected.to eq([point(13, 60), point(0, 42)].to_set) }
      end
    end
  end
end
