# frozen_string_literal: true

require 'repositories/stats'

class ApplicationController < ActionController::Base
  add_flash_types :warning, :success, :error

  def filters
    @show_filters         = { month: true }
    @filter_params        = filter_params
    @possible_years       = Repositories::Stats.possible_years
    @possible_sport_types = Repositories::Stats.possible_sport_types
  end

  def filter_params
    params.reverse_merge!(
      month: Time.now.month.to_s,
      year:  Time.now.year.to_s
    )
    {
      year:       params[:year],
      month:      params[:month],
      sport_type: params[:sport_type],
      group_by:   params[:group_by]
    }
  end

  def years
    params[:year]&.split(',')&.map(&:to_i)
  end

  def months
    params[:month]&.split(',')&.map(&:to_i)
  end

  def sport_types
    params[:sport_type]&.split(',')
  end

  def group_by
    (params[:group_by]&.split(',') || ['year']).each_with_object({}) do |v, h|
      h[v] = "$#{v}"
    end
  end

  def measure(title = nil)
    s = Time.now.to_f
    r = yield
    e = Time.now.to_f
    puts "#{title} took #{((e - s) * 1000).round(1)} ms"
    r
  end
end
