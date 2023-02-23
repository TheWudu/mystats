# frozen_string_literal: true

require 'repositories/statistics/mongo_db'

class ChartsController < ApplicationController
  before_action :filters
  before_action :chart_filters

  def chart_filters
    @path_method = 'charts_index_path'
    @show_filters[:month] = false
    @show_filters[:group_by] = true

    @possible_groups = %w[year year,month year,sport_type sport_type]
  end

  def index
    @chart_params = {
      group_by:  params[:group_by],
      yoy_group: params[:yoy_group] || "week"
    }.merge(@filter_params)
    @yoy_value = yoy_value
    @yoy_end   = yoy_end
  end

  def yoy_end
    @yoy_end ||= if @chart_params[:yoy_group] == 'week'
                   "week #{yoy_date}"
                 else
                   "day: #{yoy_date}"
                 end
  end

  def yoy_date
    @yoy_date ||= if @chart_params[:yoy_group] == 'week'
                    Time.now.strftime('%-W').to_i
                  else
                    Time.now.strftime('%-d.%-m.')
                  end
  end

  def yoy_years
    years_sorted = years.last(2)
    @yoy_years ||= [years_sorted.last, years_sorted.first].sort
  end

  def yoy_value
    stats = statistics.yoy(@chart_params[:yoy_group])
    yoy_last = stats.find { |s| s[:name] == yoy_years.last }[:data][yoy_date].to_f
    yoy_first = stats.find { |s| s[:name] == yoy_years.first }[:data][yoy_date].to_f

    (yoy_last / yoy_first).round(2) * 100
  end

  def cnt_per_weekday
    render json: statistics.cnt_per_weekday_data
  end

  def cnt_per_week_of_year
    render json: statistics.cnt_per_week_of_year
  end

  def yoy_week
    render json: statistics.yoy('week')
  end

  def yoy_day
    render json: statistics.yoy('day')
  end

  def distance_per_year
    data = statistics.data_per_year('overall_distance')
    data.transform_values! { |v| (v / 1000.0).round(1) }
    render json: data
  end

  def duration_per_year
    data = statistics.data_per_year('overall_duration')
    data.transform_values! { |v| (v / 1000 / 3600.0).round(2) }
    render json: data
  end

  def pace_per_year
    data = statistics.data_per_year('overall_pace')
    data.transform_values! { |v| (v / 60).round(2) }
    render json: data
  end

  def elevation_per_year
    render json: statistics.data_per_year('overall_elevation_gain')
  end

  def cnt_per_year
    render json: statistics.data_per_year('overall_cnt')
  end

  def distance_buckets
    render json: statistics.distance_bucket_data
  end

  def hour_per_day
    render json: statistics.hour_per_day_data
  end

  def statistics
    @statistics ||= Repositories::Statistics::MongoDb.new(
      years:,
      sport_types:,
      group_by:
    )
  end
end
