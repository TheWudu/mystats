module Repositories
  module Statistics
    class MongoDb
      attr_accessor :years, :sport_type_ids, :group_by

      def initialize(years, sport_type_ids, group_by)
        self.years = years
        self.sport_type_ids = sport_type_ids
        self.group_by = group_by
      end

      def possible_years
        query = sessions.aggregate([ 
          { "$group" => { _id: "$year", cnt: { "$sum": 1 }  } },
          { "$sort" => { _id: 1 } }
        ]) 
        query.map { |d| d["_id"] }
      end
      
      def possible_sport_types
        query = sessions.aggregate([ 
          { "$group" => { _id: "$sport_type_id", cnt: { "$sum": 1 }  } },
          { "$sort" => { _id: 1 } }
        ]) 
        query.each_with_object({}) do |d, h| 
          h[d["_id"]] = SPORT_TYPE_MAPPING[d["_id"]]
        end
      end
  
      def cnt_per_weekday_data
        query = sessions.aggregate([ 
          { "$match" => matcher }, 
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
          { "$match" => matcher }, 
          { "$group" => { _id: group_by, 
              overall_distance: { "$sum" => "$distance" },
              overall_duration: { "$sum" => "$duration" },
              overall_elevation_gain: { "$sum" => "$elevation_gain" },
              overall_cnt: { "$sum" => 1 } } },
          { "$sort" => { _id: 1 } }
        ]).to_a
        data.each_with_object({}) do |d, h|
          key = d["_id"].values.join("-")
          h[key] = d[attr]
        end
      end
  
      def distance_bucket_data
        data = sessions.aggregate([
          { "$match" => matcher }, 
          { "$match" => { distance: { "$gt" => 0 } } },
          { "$bucket" => { 
              groupBy: "$distance", 
              boundaries: [0,5000,10000,20000,100_000], 
              default: "no distance",
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
          { "$match" => matcher }, 
          { "$addFields" => { timezone: { "$ifNull" => [ "$timezone", "UTC" ] } } },
          { "$addFields" => { hour: { "$hour" => { date: "$start_time", timezone: "$timezone" } } } }, 
          { "$group" => { _id: "$hour", count: { "$sum" => 1 } } },
          { "$sort" => { _id: 1 } }
        ])

        data.each_with_object({}) do |d, h|
          h[d["_id"]] = d["count"]
        end
        
      end

      private
  
      def matcher
        m = {}
        m.merge!(year: { "$in" => years }) if years && !years.empty?
        m.merge!(sport_type_id: { "$in" => sport_type_ids }) if sport_type_ids && !sport_type_ids.empty?
        m
      end 
  
      def mongo
        self.class.mongo
      end

      def self.mongo
        @mongo ||= ::Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'mydb').database
      end
      
      def sessions
        @sessions ||= mongo[:sessions]
      end
  
      SPORT_TYPE_MAPPING = {
         1 => "running",
         3 => "cycling",
         4 => "mountain-biking",
         5 => "other",
         7 => "hiking",
         9 => "skiing",
        18 => "swimming",
        19 => "walking",
        22 => "race-cycling",
        26 => "yoga",
        31 => "pilates",
        32 => "climbing",
        34 => "strength-training",
        54 => "ice-skating",
        55 => "sledding",
        69 => "crossfit",
        70 => "dancing",
        71 => "ice-hockey",
        74 => "gymnastics",
        81 => "training",
        91 => "body-weight training"
      }
  
      MONGO_WEEKDAY_IDX_TO_NAME = {
        1 => "Sunday",
        2 => "Monday",
        3 => "Tuesday",
        4 => "Wednesday",
        5 => "Thursday",
        6 => "Friday",
        7 => "Saturday"
      }

    end
  end
end
