module Inspections
  extend ActiveSupport::Concern

  def build_inspections_arr(inspections)
    inspections_arr = []
    inspections.each do |item|
      inspection =
          {
              'id' => item['internal_id'],
              'link' => item['data'].try(:[], 'link'),
              'reason_pdf' => "http://cdn.inspections.gov.ua/#{item['internal_id']}/reason.pdf",
              'result_act_pdf' => "http://cdn.inspections.gov.ua/#{item['internal_id']}/result_act.pdf",
              'regulator' => item['regulator'],
              'activity_type' => item['data'].try(:[], 'activity_type') || item['plan'].try(:[], 'activity_type'),
              'risk' => item['data'].try(:[], 'risk') || item['plan'].try(:[], 'risk'),
              'status' => item['data'].try(:[], 'status') || item['plan'].try(:[], 'status'),
              'date_finish' =>  item['data'].try(:[], 'date_finish'),
              'sanction_sum' =>
                  if item['data'].present? && item['data']['sanction'].present?
                    item['data']['sanction'].map{|sanction| sanction['regulator']['sanction_fine_amount'].to_i}.reduce(:+)
                  end
          }

      inspections_arr.push(inspection)
    end

    inspections_arr
  end

end
