module Dashboards
  class BaseController < ApplicationController
    include ArelHelper
    include ClientEntryCalculations
    include ClientActiveCalculations

    CACHE_EXPIRY = if Rails.env.production? then 8.hours else 20.seconds end

    before_action :require_can_view_censuses!
    def index
      # Census
      @census_start_date = '2015-07-01'.to_date
      @census_end_date = 1.weeks.ago.to_date

    end

    def active
      @report = active_report_class.ordered.first
      data = @report[:data].with_indifferent_access
      @data = data[:data]
      @clients = data[:clients]
      @client_count = data[:client_count]
      @enrollments = data[:enrollments]
      @month_name = data[:month_name]
      @range = ::Filters::DateRange.new(data[:range])
      @labels = data[:labels]

      render layout: !request.xhr?
    end

    def housed
      @report = housed_report_class.ordered.first
      data = @report[:data].with_indifferent_access
      @ph_clients = data[:ph_clients]
      @ph_exits = data[:ph_exits]
      @buckets = data[:buckets]
      @all_exits_labels = data[:all_exits_labels]
      @start_date = data[:start_date]
      @end_date = data[:end_date]

      render layout: !request.xhr?
    end

    

    def entered
      @report = entered_report_class.ordered.first
      data = @report[:data].with_indifferent_access
      @enrollments_by_type = data[:enrollments_by_type]
      @client_enrollment_totals_by_type = data[:client_enrollment_totals_by_type]
      @client_entry_totals_by_type = data[:client_entry_totals_by_type]
      @first_time_total_deduplicated = data[:first_time_total_deduplicated]
      @first_time_ever = data[:first_time_ever]
      @data = data[:data]
      @labels = data[:labels]
      @start_date = data[:start_date]
      @end_date = data[:end_date]

      render layout: !request.xhr?
    end

    

    private def client_source
      raise 'Implement in sub-class'
    end

    def service_history_source
      GrdaWarehouse::ServiceHistory
    end

    def homeless_service_history_source
      service_history_source.
        where(service_history_source.project_type_column => 
        GrdaWarehouse::Hud::Project::HOMELESS_PROJECT_TYPES).
        where(client_id: client_source)
    end

    def residential_service_history_source
      service_history_source.
        where(
           service_history_source.project_type_column => GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPE_IDS
        ).
        where(client_id: client_source)
    end

    def exits_from_homelessness
      service_history_source.exit.
        joins(:client).
        where(
          service_history_source.project_type_column => GrdaWarehouse::Hud::Project::HOMELESS_PROJECT_TYPES
        ).
        where(client_id: client_source)
    end
  end
end