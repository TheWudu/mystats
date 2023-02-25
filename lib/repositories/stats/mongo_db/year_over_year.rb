# frozen_string_literal: true

require_relative './base'

module Repositories
  module Stats
    module MongoDb
      class YearOverYear < Stats::MongoDb::Base
        def execute
          data = yoy_aggregation

          res = years.each_with_object([]) do |year, result|
            result << { name: year, data: fill_days(year, data) }
          end

          OpenStruct.new(
            data:   res,
            ending: yoy_end,
            value:  yoy_value(res),
            years:  yoy_years
          )
        end

        private

        def yoy_end
          @yoy_end ||= case group_by
                       when 'week'
                         "week #{yoy_date}"
                       when 'month'
                         "month #{yoy_date}"
                       else
                         "day: #{yoy_date}"
                       end
        end

        def yoy_date
          @yoy_date ||= case group_by
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

        def yoy_value(stats)
          yoy_last  = stats.find { |s| s[:name] == yoy_years.last }[:data][yoy_date].to_f
          yoy_first = stats.find { |s| s[:name] == yoy_years.first }[:data][yoy_date].to_f

          return 0.0 if yoy_first == 0.0

          (yoy_last / yoy_first * 100).round(1)
        end

        def yoy_aggregation
          group = case group_by
                  when 'week'
                    { year: '$iso_week_year', week: '$iso_week' }
                  when 'day'
                    { year: '$iso_week_year', day: '$date' }
                  when 'month'
                    { year: '$iso_week_year', month: '$month' }
                  end
          data = sessions.aggregate([
                                      { '$match' => matcher },
                                      { '$addFields' => {
                                        timezone: { '$ifNull' => ['$timezone', 'UTC'] },
                                         date: { '$dateToString' => { date:     '$start_time',
                                                                      timezone: '$timezone',
                                                                      format:   '%Y-%m-%d' } },
                                        'iso_week'      => { '$isoWeek' => '$start_time' },
                                        'iso_week_year' => { "$isoWeekYear": '$start_time' }
                                      } },
                                      { '$group' => { _id:      group,
                                                      distance: { '$sum' => '$distance' } } },
                                      { '$sort' => { _id: 1 } }
                                    ]).to_a
        end

        def group_key(doc)
          case group_by
          when 'day'
            Date.parse(doc['_id']['day']).strftime('%-d.%-m.')
          when 'week'
            doc['_id']['week']
          when 'month'
            doc['_id']['month']
          end
        end

        def assign_data(result, year, data)
          data.each do |d|
            next if d.dig('_id', 'year') != year

            key = group_key(d)
            result[key] = d['distance'] / 1000.0
          end
        end

        def fill_days(year, data)
          r = case group_by
              when 'day'
                initialize_days(year)
              when 'week'
                initialize_weeks
              when 'month'
                initialize_months
              else
                raise NotImplementedError
              end

          assign_data(r, year, data)
          apply_sums(r)
        end

        def initialize_days(year)
          (Date.parse("#{year}-01-01")..Date.parse("#{year}-12-31")).each_with_object({}) do |day, hash|
            hash["#{day.day}.#{day.month}."] = 0
          end
        end

        def initialize_weeks
          (0..52).each_with_object({}) do |week, hash|
            hash[week] = 0
          end
        end

        def initialize_months
          (1..12).each_with_object({}) do |week, hash|
            hash[week] = 0
          end
        end

        def apply_sums(result)
          year_sum = 0

          result.each do |k, v|
            year_sum += v
            result[k] = year_sum.round(2)
          end
          result
        end
      end
    end
  end
end
