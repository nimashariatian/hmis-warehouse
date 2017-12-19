module GrdaWarehouse::WarehouseReports::Dashboard
  class Base < GrdaWarehouse::WarehouseReports::Base
    include ArelHelper

    def self.sub_populations_by_type
      {
        active: {
          veteran: GrdaWarehouse::WarehouseReports::Dashboard::Veteran::ActiveClients,
          all_clients: GrdaWarehouse::WarehouseReports::Dashboard::AllClients::ActiveClients,
        },
        entered: {
          veteran: GrdaWarehouse::WarehouseReports::Dashboard::Veteran::EnteredClients,
          all_clients: GrdaWarehouse::WarehouseReports::Dashboard::AllClients::EnteredClients,
        },
        housed: {
          veteran: GrdaWarehouse::WarehouseReports::Dashboard::Veteran::HousedClients,
          all_clients: GrdaWarehouse::WarehouseReports::Dashboard::AllClients::HousedClients,
        }, 
      }
    end

    def self.available_sub_populations
      {
        'All Clients' => :all_clients, 
        'Veterans' => :veteran
      }
    end

    def service_history_source
      GrdaWarehouse::ServiceHistory
    end

    def homeless_service_history_source
      service_history_source.
        joins(:client).
        where(
          service_history_source.project_type_column => GrdaWarehouse::Hud::Project::HOMELESS_PROJECT_TYPES
        ).
        where(client_id: client_source)
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

    def service_history_columns
      {
        client_id: sh_t[:client_id].as('client_id').to_sql, 
        project_id:  sh_t[:project_id].as('project_id').to_sql, 
        first_date_in_program:  sh_t[:first_date_in_program].as('first_date_in_program').to_sql, 
        last_date_in_program:  sh_t[:last_date_in_program].as('last_date_in_program').to_sql, 
        project_name:  sh_t[:project_name].as('project_name').to_sql, 
        project_type:  sh_t[service_history_source.project_type_column].as('project_type').to_sql, 
        organization_id:  sh_t[:organization_id].as('organization_id').to_sql,
        first_name: c_t[:FirstName].as('first_name').to_sql,
        last_name: c_t[:LastName].as('last_name').to_sql,
      }
    end

    def colorize(object)
      # make a hash of the object, truncate it to an appropriate size and then turn it into
      # a css friendly hash code
      "#%06x" % (Zlib::crc32(Marshal.dump(object)) & 0xffffff)
    end

  end
end