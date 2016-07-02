require 'open-uri'
require 'json'
E = Math::atan(Math::sinh(Math::PI)) # known as 85.0511 deg

class Float
  def to_degree
    self * 360.0 / 2 / Math::PI
  end
end

def distance(lng0, lat0, lng1, lat1)
  url = "http://vldb.gsi.go.jp/sokuchi/surveycalc/surveycalc/bl2st_calc.pl?outputType=json&ellipsoid=GRS80&latitude1=#{lat0}&longitude1=#{lng0}&latitude2=#{lat1}&longitude2=#{lng1}"
  JSON::parse(open(url).read)['OutputData']['geoLength'].to_f
end

def work_on(z)
  lng0 = 0
  lat0 = 0
  lng1 = 360.0 / (2 ** z)
  lat0 = E.to_degree
  lat1 = (E - (2.0 * E / (2 ** z))).to_degree
  north_distance = distance(lng0, lat0, lng1, lat0)
  south_distance = distance(lng0, lat1, lng1, lat1)
  print <<-EOS
#{z}/0/0
  north #{north_distance}m 
  south #{south_distance}m 
  difference #{south_distance - north_distance}m, #{(south_distance - north_distance) / south_distance * 100}%, #{(south_distance - north_distance) / south_distance * 256}px
  EOS
end

14.upto(20) {|z|
  work_on(z)
}
