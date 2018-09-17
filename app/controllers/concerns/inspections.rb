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
          'status' => status(item),
          'date_finish' =>  item['data'].try(:[], 'date_finish') || '',
          'sanction_sum' => calculate_sum(item).to_s || '',
          'reason_pdf' => document_link?(item) ? "http://cdn.inspections.gov.ua/#{item['internal_id']}/reason.pdf" : '',
          'result_act_pdf' => document_link?(item) ?  "http://cdn.inspections.gov.ua/#{item['internal_id']}/result_act.pdf" : ''
        }

      inspections_arr.push(inspection)
    end

    inspections_arr
  end

  def document_link?(item)
    status(item).eql?('Проведено')
  end

  def status(item)
    item['data'].try(:[], 'status') || item['plan'].try(:[], 'status')
  end

  def calculate_sum(item)
    if item['data'].present? && item['data']['sanction'].present?
      item['data']['sanction'].map{|sanction| sanction['regulator']['sanction_fine_amount'].to_i}.reduce(:+)
    end
  end

end
