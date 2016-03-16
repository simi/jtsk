require 'spec_helper'

describe JTSK::Converter do
  let(:converter) { described_class.new }
  let(:x) { 1043033.89 }
  let(:y) { 738371.58 }
  let(:result) { converter.to_wgs84(x,y) }

  it 'to_wgs48 is deprecated' do
    expect(converter).to receive(:warn)
    deprecated_result = converter.to_wgs48(x,y)
    expect(deprecated_result).to be_kind_of(JTSK::Wgs48Result)
  end

  it 'EPS is properly set' do
    expect(described_class::EPS).to eq(1e-4)
  end

  it 'can be initialized' do
    expect(converter).to be_kind_of(described_class)
  end

  it 'result is JTSK::Result' do
    expect(result).to be_kind_of(JTSK::Wgs84Result)
  end

  context 'Club Velbloud' do
    let(:x) { 1043033.89 }
    let(:y) { 738371.58 }
    it 'calucaltes well' do
      expect(result.latitude).to eq(50.092696246901404)
      expect(result.longitude).to eq(14.482746557404647)
    end
  end

  context 'Indian Bar' do
    let(:x) { 1043070.32 }
    let(:y) { 738988.72 }
    it 'calculates well' do
      expect(result.latitude).to eq(50.091628136117045)
      expect(result.longitude).to eq(14.474266228665831)
    end
  end
end
