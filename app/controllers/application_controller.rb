# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def years
    params[:year]&.split(',')&.map(&:to_i)
  end

  def months
    params[:month]&.split(',')&.map(&:to_i)
  end

  def sport_type_ids
    params[:sport_type_id]&.split(',')&.map(&:to_i)
  end

  def group_by
    (params[:group_by]&.split(',') || ['year']).each_with_object({}) do |v, h|
      h[v] = "$#{v}"
    end
  end
end
