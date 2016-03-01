class Reports::EntriesController < ApplicationController

  def show
    @from = report_params[:from].present? ? Date.parse(report_params[:from]) : Date.today.beginning_of_week
    @to = report_params[:to].present? ? Date.parse(report_params[:to]) : Date.today

    reporter = ::Reports::Entries.new(@from, @to, current_user)

    @entries = {
      regular: reporter.regular_entries_for,
      holiday: reporter.holiday_entries_for
    }
  end

  private

  def report_params
    params.permit(:from, :to, users: [])
  end

end
