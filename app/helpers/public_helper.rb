module PublicHelper
  def timeline_currentevent_num events
    events.where(:starts_at.lte => Date.current).count
  end

end
