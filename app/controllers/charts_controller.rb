require "repositories/statistics/mongo_db"

class ChartsController < ApplicationController
  def index
    @chart_params = {
      year:     params[:year],
      group_by: params[:group_by],
      sport_type_id: params[:sport_type_id]
    }

    @possible_years = statistics.possible_years
    @possible_sport_types = statistics.possible_sport_types
  end

  def cnt_per_weekday
    render json: statistics.cnt_per_weekday_data
  end

  def distance_per_year 
    data = statistics.data_per_year("overall_distance")
    data.transform_values! { |v| v / 1000.0 }
    render json: data
  end
  
  def duration_per_year 
    data = statistics.data_per_year("overall_duration")
    data.transform_values! { |v| v / 1000 }
    render json: data
  end
  
  def elevation_per_year 
    render json: statistics.data_per_year("overall_elevation_gain")
  end
  
  def cnt_per_year 
    render json: statistics.data_per_year("overall_cnt")
  end
  
  def distance_buckets
    render json: statistics.distance_bucket_data
  end

  def hour_per_day
    render json: statistics.hour_per_day_data
  end

  def statistics
    @statistics ||= Repositories::Statistics::MongoDb.new(years, sport_type_ids, group_by)
  end

  def years
    params[:year]&.split(",")&.map(&:to_i)
  end

  def group_by
    (params[:group_by]&.split(",") || ["year"]).each_with_object({}) do |v,h|
      h[v] = "$#{v}"
    end
  end

  def sport_type_ids
    params[:sport_type_id]&.split(",")&.map(&:to_i)
  end
 
end
