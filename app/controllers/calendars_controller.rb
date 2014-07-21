class CalendarsController < ApplicationController
  def show
    @city_actions = CalendarAction.where(:holder => '1')
    @people_actions = CalendarAction.where(:holder => '2')
  end
end
