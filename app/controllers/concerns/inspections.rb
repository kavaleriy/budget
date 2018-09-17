module Inspections
  extend ActiveSupport::Concern

  def build_inspections_arr(inspections)
    inspections_arr = []
    inspections.each do |item|
      inspection =
        {
          'id' => item['internal_id'],
          'link' => item['data'].try(:[], 'link') || item['plan'].try(:[], 'link'),
          'regulator' => item['regulator'],
          'activity_type' => item['data'].try(:[], 'activity_type') || item['plan'].try(:[], 'activity_type'),
          'risk' => item['data'].try(:[], 'risk') || item['plan'].try(:[], 'risk'),
          'status' => item['data'].try(:[], 'status') || item['plan'].try(:[], 'status'),
          'date_start' => (item['data'].try(:[], 'date_start') || item['plan'].try(:[], 'date_start') || '').try(:slice, 0, 10),
          'date_finish' => item['data'].try(:[], 'date_finish').try(:slice, 0, 10) || '',
          'sanction_sum' => calculate_sum(item).to_s || ''
        }

      inspections_arr.push(inspection)
    end

    inspections_arr
  end

  def calculate_sum(item)
    if item['data'].present? && item['data']['sanction'].present?
      item['data']['sanction'].map{|sanction| sanction['regulator']['sanction_fine_amount'].to_i}.reduce(:+)
    end
  end

end
