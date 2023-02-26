# frozen_string_literal: true

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
    @yoy_stats ||= yoy_stats
  end

  def yoy_stats
    @yoy_stats ||= Repositories::Stats.year_over_year(years:,
                                                      sport_types:,
                                                      group_by:    @chart_params[:yoy_group])
  end

  def cnt_per_weekday
    render json: Repositories::Stats.count_per_weekday(
      years:,
      sport_types:,
      group_by:
    )
  end

  def cnt_per_week_of_year
    render json: Repositories::Stats.count_per_week_of_year(
      years:,
      sport_types:,
      group_by:
    )
  end

  def yoy
    render json: yoy_stats.data
  end

  def distance_per_year
    data = overall_aggregations('overall_distance')
    data.transform_values! { |v| (v / 1000.0).round(1) }
    render json: data
  end

  def duration_per_year
    data = overall_aggregations('overall_duration')
    data.transform_values! { |v| (v / 1000 / 3600.0).round(2) }
    render json: data
  end

  def pace_per_year
    data = overall_aggregations('overall_pace')
    data.transform_values! { |v| (v / 60).round(2) }
    render json: data
  end

  def elevation_per_year
    render json: overall_aggregations('overall_elevation_gain')
  end

  def cnt_per_year
    render json: overall_aggregations('overall_cnt')
  end

  def overall_aggregations(attribute)
    Repositories::Stats.overall_aggregations(
      years:,
      sport_types:,
      group_by:,
      attribute:
    )
  end

  def distance_buckets
    render json: Repositories::Stats.distance_bucket(
      years:,
      sport_types:,
      group_by:
    )
  end

  def count_per_hour_of_day
    render json: Repositories::Stats.count_per_hour_of_day(
      years:,
      sport_types:,
      group_by:
    )
  end
end
