# frozen_string_literal: true

require 'use_cases/traces/matcher'

class TraceMatcherController < ApplicationController
  def index
    @matcher = UseCases::Traces::Matcher.new(
      trace1:     t1, 
      trace2:     t2,
      block_size: block_size,
      max_diff:   max_diff,
      min_overlap: min_overlap
    )
    @matcher.analyse
    @match_params = {
      block_size: params[:block_size],
      min_overlap: params[:min_overlap],
      max_diff: params[:max_diff]
    }
  end

  private

  def min_overlap
    params[:min_overlap].blank? ? nil : params[:min_overlap]
  end

  def block_size
    params[:block_size].blank? ? nil : params[:block_size]
  end

  def max_diff
    params[:max_diff].blank? ? nil : params[:max_diff]
  end

  def t1
    s1 = Repositories::Sessions::MongoDb.new.find_by_id(id: "8cda6b14-9dda-4564-ab75-d87cbd0d641d")
    s1[:trace]
  end

  def t2
    s2 = Repositories::Sessions::MongoDb.new.find_by_id(id: "cf8fae76-3c18-458f-9066-d859dfd73cac")
    s2[:trace]
  end

end
