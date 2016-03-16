module JTSK
  class Wgs84Result < Struct.new(:latitude, :longitude)
  end
  class Wgs48Result < Struct.new(:latitude, :longitude)
  end
  class BesselResult < Struct.new(:latitude, :longitude)
  end
  class JtskResult < Struct.new(:x, :y)
  end
end
