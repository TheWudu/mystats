# frozen_string_literal: true

require 'repositories/statistics/mongo_db'
require 'repositories/stats'

class ChartsController < ApplicationController
  before_action :filters
  before_action :chart_filters

  def chart_filters
    @path_method = 'charts_index_path'
    @show_filters[:month] = false
    @show_filters[:group_by] = true

    @chart_params = {
      group_by:  params[:group_by],
      yoy_group: params[:yoy_group] || 'week'
    }.merge(@filter_params)

    @possible_groups = %w[year year,month year,sport_type sport_type]
  end

  def index
    @yoy_value = yoy_value
    @yoy_end   = yoy_end
  end

  def yoy_end
    @yoy_end ||= case @chart_params[:yoy_group]
                 when 'week'
                   "week #{yoy_date}"
                 when 'month'
                   "month #{yoy_date}"
                 else
                   "day: #{yoy_date}"
                 end
  end

  def yoy_date
    @yoy_date ||= case @chart_params[:yoy_group]
                  when 'week'
                    Time.now.strftime('%-W').to_i
                  when 'month'
                    Time.now.strftime('%-m').to_i
                  when 'day'
                    Time.now.strftime('%-d.%-m.')
                  end
  end

  def yoy_years
    years_sorted = years.sort.last(2)
    @yoy_years ||= [years_sorted.last, years_sorted.first].sort
  end

  def yoy_stats
    @yoy_stats ||= Repositories::Stats.year_over_year(years:,
                                                      sport_types:,
                                                      group_by:    @chart_params[:yoy_group])
  end

  def yoy_value
    return '-' if yoy_stats.empty?

    yoy_last = yoy_stats.find { |s| s[:name] == yoy_years.last }[:data][yoy_date].to_f
    yoy_first = yoy_stats.find { |s| s[:name] == yoy_years.first }[:data][yoy_date].to_f

    (yoy_last / yoy_first * 100).round(1)
  end

  def cnt_per_weekday
    render json: statistics.cnt_per_weekday_data
  end

  def cnt_per_week_of_year
    render json: statistics.cnt_per_week_of_year
  end

  def yoy
    render json: yoy_stats
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
