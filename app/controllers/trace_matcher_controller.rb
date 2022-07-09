# frozen_string_literal: true

require 'use_cases/traces/matcher'

class TraceMatcherController < ApplicationController
  def index
    @matcher = UseCases::Traces::Matcher.new(
      trace1: trace1,
      trace2: trace2,
      block_size: block_size,
      max_diff: max_diff,
      min_overlap: min_overlap
    )
    @matcher.analyse
    @match_params = {
      block_size: params[:block_size] || UseCases::Traces::Matcher::BLOCK_SIZE_IN_METERS,
      min_overlap: params[:min_overlap] || UseCases::Traces::Matcher::MIN_OVERLAP,
      max_diff: params[:max_diff] || UseCases::Traces::Matcher::MAX_DIFF,
      session1: session1_id,
      session2: session2_id
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

  def session1_id
    params[:session1] || '8cda6b14-9dda-4564-ab75-d87cbd0d641d'
  end

  def session2_id
    params[:session2] || 'cf8fae76-3c18-458f-9066-d859dfd73cac'
  end

  def session1
    @session1 ||= OpenStruct.new(Repositories::Sessions::MongoDb.new.find_by_id(id: session1_id))
  end

  def trace1
    @trace1 ||= session1[:trace]
  end

  def session2
    @session2 ||= OpenStruct.new(Repositories::Sessions::MongoDb.new.find_by_id(id: session2_id))
  end

  def trace2
    @trace2 ||= session2[:trace]
  end
end
