module ServiceHistoryServiceConcern
  extend ActiveSupport::Concern
  included do
    scope :service, -> { where record_type: service_types }
    scope :extrapolated, -> { where record_type: :extrapolated }
    # The following scope is sometimes used to determine if any "real" service
    # was performed within a date range, it isn't correctly interpreted 
    # if used with ServiceHistoryEnrollment.with_service_between
    # unless it is explicitly a string
    scope :service_excluding_extrapolated, -> { where("record_type = 'service'") }

    scope :residential, -> {
      where(project_type_column => GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPE_IDS)
    }

    scope :hud_residential, -> do
      hud_project_type(GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPE_IDS)
    end

    scope :residential_non_homeless, -> do
      r_non_homeless = GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPE_IDS - GrdaWarehouse::Hud::Project::HOMELESS_PROJECT_TYPES
      where(project_type_column => r_non_homeless)
    end
    scope :hud_residential_non_homeless, -> do
      r_non_homeless = GrdaWarehouse::Hud::Project::RESIDENTIAL_PROJECT_TYPE_IDS - GrdaWarehouse::Hud::Project::CHRONIC_PROJECT_TYPES
      hud_project_type(r_non_homeless)
    end

    scope :homeless, -> (chronic_types_only: false) do
      if chronic_types_only
        project_types = GrdaWarehouse::Hud::Project::CHRONIC_PROJECT_TYPES
      else
        project_types = GrdaWarehouse::Hud::Project::HOMELESS_PROJECT_TYPES
      end

      where(project_type_column => project_types)
    end

    scope :hud_homeless, -> (chronic_types_only: true) do
      hud_project_type(GrdaWarehouse::Hud::Project::CHRONIC_PROJECT_TYPES)
    end

    scope :in_project_type, -> (project_types) do
      where(project_type_column => project_types)
    end

    scope :service_within_date_range, -> (start_date: , end_date: ) do
      at = arel_table
      service.where(at[:date].gteq(start_date).and(at[:date].lteq(end_date)))
    end

    scope :service_in_last_three_years, -> {
      service_within_date_range(start_date: 3.years.ago.to_date, end_date: Date.today)
    }

    def self.service_types
      service_types = ['service']
      if GrdaWarehouse::Config.get(:so_day_as_month)
        service_types << 'extrapolated'
      end
    end
  end
end