class ChartsController < ApplicationController
  def index
  end

  def cnt_per_weekday
    render json: cnt_per_weekday_data
  end

  def distance_per_year 
    data = data_per_year("overall_distance")
    data.transform_values! { |v| v / 1000.0 }
    render json: data
  end
  
  def duration_per_year 
    data = data_per_year("overall_duration")
    data.transform_values! { |v| v / 1000 }
    render json: data
  end
  
  def elevation_per_year 
    render json: data_per_year("overall_elevation_gain")
  end
  
  def cnt_per_year 
    render json: data_per_year("overall_cnt")
  end
  
  def distance_buckets
    render json: distance_bucket_data
  end

  def hour_per_day
    render json: hour_per_day_data
  end

  MONGO_WEEKDAY_IDX_TO_NAME = {
    1 => "Sunday",
    2 => "Monday",
    3 => "Tuesday",
    4 => "Wednesday",
    5 => "Thursday",
    6 => "Friday",
    7 => "Saturday"
  }

  def cnt_per_weekday_data
    query = sessions.aggregate([ 
      { "$match" => { year: { "$in" => years }, sport_type_id: 1 } }, 
      { "$addFields" => { weekday: { "$dayOfWeek" => "$start_time" } } }, 
      { "$group" => { _id: "$weekday", cnt: { "$sum" => 1 } } },
      { "$sort" => { _id: 1 } }
    ])
    
    data = query.to_a.rotate(1)
    data.each_with_object({}) do |d, h|
      name = MONGO_WEEKDAY_IDX_TO_NAME[d["_id"]]
      h[name] = d["cnt"]
    end
  end

  def data_per_year(attr)
    data = sessions.aggregate([ 
      { "$match" => { sport_type_id: { "$in" => [1] } } }, 
      { "$group" => { _id: "$year", 
          overall_distance: { "$sum" => "$distance" },
          overall_duration: { "$sum" => "$duration" },
          overall_elevation_gain: { "$sum" => "$elevation_gain" },
          overall_cnt: { "$sum" => 1 } } },
      { "$sort" => { _id: 1 } }
    ]).to_a
    data.each_with_object({}) do |d, h|
      h[d["_id"]] = d[attr]
    end
  end

  def distance_bucket_data
    data = sessions.aggregate([
      { "$match" => { year: { "$in" => years }, sport_type_id: 1 } }, 
      { "$bucket" => { 
          groupBy: "$distance", 
          boundaries: [0,5000,10000,20000,100_000], 
          output: { 
            total: { "$sum" => 1 }, 
            avg_distance: { "$avg" => "$distance" }, 
            sum_distance: { "$sum" => "$distance" }, 
            sum_duration: { "$sum" => "$duration" } 
          } 
        } 
      }
    ])

    data.each_with_object({}) do |d, h|
      h[d["_id"]] = d["total"]
    end
  end

  def hour_per_day_data
    data = sessions.aggregate([ 
      { "$match" => { year: { "$in" => years }, sport_type_id: { "$in" => [1] } } }, 
      { "$addFields" => { timezone: { "$ifNull" => [ "$timezone", "UTC" ] } } },
      { "$addFields" => { hour: { "$hour" => { date: "$start_time", timezone: "$timezone" } } } }, 
      { "$group" => { _id: "$hour", count: { "$sum" => 1 } } },
      { "$sort" => { _id: 1 } }
    ])

    data.each_with_object({}) do |d, h|
      h[d["_id"]] = d["count"]
    end
    
  end


  def years
    [Time.now.year]
  end

  def mongo
    @mongo ||= Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'mydb').database
  end
  
  def sessions
    @sessions ||= mongo[:sessions]
  end

 
end
