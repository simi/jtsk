module JTSK
  class Converter
    EPS = 1e-4

    def to_wgs48(x, y)
      delta = 5.0
      latitude = 49.0
      longitude = 14.0
      steps = 0.0

      loop {

        jtsk = self.wgs48_to_jtsk(latitude - delta, longitude - delta)
        if(jtsk.x && jtsk.y)
          v1 = self.dist_points(jtsk.x, jtsk.y, x, y)
        else
          v1 = 1e32
        end

        jtsk = self.wgs48_to_jtsk(latitude - delta, longitude + delta)
        if(jtsk.x && jtsk.y)
          v2 = self.dist_points(jtsk.x, jtsk.y, x, y)
        else
          v2 = 1e32
        end

        jtsk = self.wgs48_to_jtsk(latitude + delta, longitude - delta)
        if(jtsk.x && jtsk.y)
          v3 = self.dist_points(jtsk.x, jtsk.y, x, y)
        else
          v3 = 1e32
        end

        jtsk = self.wgs48_to_jtsk(latitude + delta, longitude + delta)
        if(jtsk.x && jtsk.y)
          v4 = self.dist_points(jtsk.x, jtsk.y, x, y)
        else
          v4 = 1e32
        end

        if ((v1 <= v2) && (v1 <= v3) && (v1 <= v4))
          latitude = latitude - delta / 2.0
          longitude = longitude - delta / 2.0
        end

        if ((v2 <= v1) && (v2 <= v3) && (v2 <= v4))
          latitude = latitude - delta / 2.0
          longitude = longitude + delta / 2.0
        end

        if ((v3 <= v1) && (v3 <= v2) && (v3 <= v4))
          latitude = latitude + delta / 2.0
          longitude = longitude - delta / 2.0
        end

        if ((v4 <= v1) && (v4 <= v2) && (v4 <= v3))
          latitude = latitude + delta / 2.0
          longitude = longitude + delta / 2.0
        end

        delta = delta * 0.55;
        steps = steps + 4.0;

        break if (((delta < 0.00001) || steps > 1000.0));
      }

      JTSK::Wgs48Result.new(latitude, longitude)
    end

    def wgs48_to_jtsk(latitude, longitude)
      if ((latitude < 40.0) || (latitude > 60.0) || (longitude < 5.0) || (longitude > 25.0))
        JTSK::JtskResult.new(0.0, 0.0)
      else
        bessel = self.wgs48_to_bessel(latitude, longitude);
        self.bessel_to_jtsk(bessel.latitude, bessel.longitude);
      end
    end

    def wgs48_to_bessel(latitude, longitude, altitude = 0.0)
      b = deg2rad(latitude)
      l = deg2rad(longitude)
      h = altitude;

      x1, y1, z1 = self.blh_to_geo_coords(b, l, h)
      x2, y2, z2 = self.transform_coords(x1, y1, z1)
      b, l, h = self.geo_coords_to_blh(x2, y2, z2)

      latitude = rad2deg(b);
      longitude = rad2deg(l);
      # altitude = h;

      JTSK::BesselResult.new(latitude, longitude)
    end

    def bessel_to_jtsk(latitude, longitude)
      # a     = 6377397.15508
      e     = 0.081696831215303
      n     = 0.97992470462083
      rho_0 = 12310230.12797036
      sinUQ = 0.863499969506341
      cosUQ = 0.504348889819882
      sinVQ = 0.420215144586493
      cosVQ = 0.907424504992097
      alfa  = 1.000597498371542
      k_2   = 1.00685001861538

      b = deg2rad(latitude)
      l= deg2rad(longitude)

      sinB = Math.sin(b)
      t = (1 - e * sinB) / (1 + e * sinB)
      t = pow(1 + sinB, 2) / (1 - pow(sinB, 2)) * Math.exp(e * Math.log(t))
      t = k_2 * Math.exp(alfa * Math.log(t))

      sinU  = (t - 1) / (t + 1)
      cosU  = Math.sqrt(1 - sinU * sinU)
      v     = alfa * l
      sinV  = Math.sin(v)
      cosV  = Math.cos(v)
      cosDV = cosVQ * cosV + sinVQ * sinV
      sinDV = sinVQ * cosV - cosVQ * sinV
      sinS  = sinUQ * sinU + cosUQ * cosU * cosDV
      cosS  = Math.sqrt(1 - sinS * sinS)
      sinD  = sinDV * cosU / cosS
      cosD  = Math.sqrt(1 - sinD * sinD)

      eps = n * Math.atan(sinD / cosD)
      rho = rho_0 * Math.exp(-n * Math.log((1 + sinS) / cosS))

      JTSK::JtskResult.new(rho * Math.cos(eps), rho * Math.sin(eps))
    end

    def blh_to_geo_coords(b,l,h)
      # WGS-84 ellipsoid parameters
      a   = 6378137.0;
      f_1 = 298.257223563;
      e2  = 1 - ((1 - 1 / f_1) ** 2)
      rho = a / Math.sqrt(1 - e2 * (Math.sin(b) ** 2))
      x = (rho + h) * Math.cos(b) * Math.cos(l)
      y = (rho + h) * Math.cos(b) * Math.sin(l)
      z = ((1 - e2) * rho + h) * Math.sin(b);

      return x, y, z;
    end

    def transform_coords(xs, ys, zs)
      # coeficients of transformation from WGS-84 to JTSK
      dx = -570.69; dy = -85.69; dz = -462.84; # shift

      # rotation
      wx = 4.99821/3600.0 * Math::PI / 180.0
      wy = 1.58676/3600.0 * Math::PI / 180.0
      wz = 5.2611/3600.0 * Math::PI / 180.0
      m  = -3.543e-6; # scale

      xn = dx + (1 + m) * (+xs + wz * ys - wy * zs);
      yn = dy + (1 + m) * (-wz * xs + ys + wx * zs);
      zn = dz + (1 + m) * (+wy * xs - wx * ys + zs);

      return xn, yn, zn
    end

    def geo_coords_to_blh(x, y, z)
      # Bessel's ellipsoid parameters
      a   = 6377397.15508
      f_1 = 299.152812853
      a_b = f_1 / (f_1-1)
      p   = Math.sqrt(pow(x, 2) + pow(y, 2))
      e2  = 1 - pow(1 - 1 / f_1, 2)
      th  = Math.atan(z * a_b / p)
      st  = Math.sin(th)
      ct  = Math.cos(th)
      t   = (z + e2 * a_b * a * pow(st, 3)) / (p - e2 * a * pow(ct, 3))

      b = Math.atan(t)
      h = Math.sqrt(1 + t * t) * (p - a / Math.sqrt(1 + (1 - e2) * t * t))
      l = 2 * Math.atan(y / (p + x))

      return b, l, h
    end

    def dist_points(x1, y1, x2, y2)
      dist = Math.hypot(x1 - x2, y1 - y2)

      if (dist < self.class::EPS)
        return 0
      end

      return dist
    end

    private

    def deg2rad(degrees)
      degrees * (Math::PI / 180.0 )
    end

    def rad2deg(radians)
      radians * (180.0 / Math::PI)
    end

    def pow(a,b)
      a ** b
    end
  end
end
