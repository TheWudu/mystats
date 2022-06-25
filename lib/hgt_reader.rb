
class HgtReader
  UNKNOWN_ELEVATION = -32768
  THREE_ARC_SECONDS = (3.0 / 60 / 60)
  INT_MAX = 2^(32-1)

  def elevation(lat, lng)
    # find n,s,w,e values for which srtm3 data exists
    lat_help = (lat / THREE_ARC_SECONDS);
    lng_help = (lng / THREE_ARC_SECONDS);

    north = lat_help.ceil  * THREE_ARC_SECONDS;
    south = lat_help.floor * THREE_ARC_SECONDS;
    east =  lng_help.ceil  * THREE_ARC_SECONDS;
    west =  lng_help.floor * THREE_ARC_SECONDS;

    # get the elevation for these ne,nw,se,sw points
    elevation_ne = from_lat_lng(north,east);
    elevation_nw = from_lat_lng(north,west);
    elevation_se = from_lat_lng(south,east);
    elevation_sw = from_lat_lng(south,west);

    elevation_north = -INT_MAX;
    elevation_south = -INT_MAX; 
   
  # some fallbacks for edge-cases      
    if(east == west)
      elevation_north = elevation_nw; 
      elevation_south = elevation_sw;
    end
      
    if(elevation_ne == UNKNOWN_ELEVATION)
      elevation_north = elevation_nw;
    end
    if(elevation_nw == UNKNOWN_ELEVATION)
      elevation_north = elevation_ne;
    end
    if(elevation_se == UNKNOWN_ELEVATION)
      elevation_south = elevation_sw;
    end
    if(elevation_sw == UNKNOWN_ELEVATION)
      elevation_south = elevation_se;
    end
    
    # do an interpolation if north/south are not unknown
    if(elevation_north == -INT_MAX) 
      elevation_north = (east - lng) / THREE_ARC_SECONDS * elevation_nw + (lng - west) / THREE_ARC_SECONDS * elevation_ne; # horizontal interpolation (north)
    end
    
    if(elevation_south == -INT_MAX)
      elevation_south = (east-lng)/THREE_ARC_SECONDS*elevation_sw + (lng-west)/THREE_ARC_SECONDS*elevation_se; # horizontal interpolation (south)
    end
    
    elevation = -0.0;
    
    if(north == south)
      elevation = elevation_south; 
    end
    
    if(elevation_north == UNKNOWN_ELEVATION)
      elevation = elevation_south;
    end
    if(elevation_south == UNKNOWN_ELEVATION)
      elevation = elevation_north;
    end
      
    if(elevation == -0.0)
      elevation = (north - lat)/THREE_ARC_SECONDS*elevation_south + (lat-south)/THREE_ARC_SECONDS*elevation_north;
    end
    
    elevation
  end


  def from_lat_lng(lat, lng)
    latDegreef = lat.abs
    lngDegreef = lng.abs

    latDegree = latDegreef.floor
    lngDegree = lngDegreef.floor


    latMinutef = (latDegreef - latDegree) * 60;
    lngMinutef = (lngDegreef - lngDegree) * 60;
     
    latMinute = latMinutef.floor
    lngMinute = lngMinutef.floor
    
    latSecond = ((latMinutef-latMinute)*60).round
    lngSecond = ((lngMinutef-lngMinute)*60).round
     
    latOrientation = lat < 0 ? 'S' : 'N';
    lngOrientation = lng < 0 ? 'W' : 'E';
          
    latDegree = (lat < 0) ? latDegree + 1 : latDegree;
    lngDegree = (lng < 0) ? lngDegree + 1 : lngDegree;

    filename = "#{latOrientation}#{latDegree}#{lngOrientation}#{lngDegree.to_s.rjust(3,"0")}.hgt"
 
    # puts "file #{filename}";

    line = latMinute * 20 + (latSecond * 0.333333333).round;
    if(lat >= 0)
      line = 1201 - (line + 1);
    end

    sample = lngMinute * 20 + (lngSecond * 0.333333).round

    if(lng < 0)
      sample = 1200 - sample;
    end

    # puts "line #{line} sample: #{sample}"

    position = (line * 1201 + sample) * 2;
    
    # puts "position #{position}"

    from_file(filename, position)
  end

  def from_file(filename, position)
    elevation = UNKNOWN_ELEVATION;

    filepath = srtm3_folder + filename;

    f = File.open(filepath, "rb");
    if(!f)
      puts "Missing file: #{filepath}"
      raise filename;
    end
    f.seek(position, IO::SEEK_SET);
    elevation = (f.getbyte * 256 + f.getbyte);

    # If the elevation (read as an unsigned int but is an signed int actually) 
    # is lager than 32768 (which is the max value of an signed int) we have to
    # substract 65535 to become the negative value.
    if(elevation >= 32768)
      elevation -= 65536;
    end

    f.close

    elevation
  end

  def srtm3_folder
    @srtm3_folder ||= begin
      root = Rails.root
      "#{root}/public/srtm3/"
    end
  end
end
