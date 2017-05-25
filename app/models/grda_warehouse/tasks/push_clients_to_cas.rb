module GrdaWarehouse::Tasks
  class PushClientsToCas
    require 'ruby-progressbar'
    attr_accessor :logger, :send_notifications
    def initialize()
      @send_notifications = Rails.env.development? || Rails.env.production?
      if @send_notifications
        slack_url = Rails.application.config_for(:exception_notifier)['slack']['webhook_url']
        channel = Rails.application.config_for(:exception_notifier)['slack']['channel']
        @notifier = Slack::Notifier.new slack_url, channel: channel, username: 'ClientCleanup'
      end
      self.logger = Rails.logger
    end

    # Update the ProjectClient table in the CAS with clients flagged with sync_with_cas 
    def sync!
      @client_ids = client_source.pluck(:id)
      updated_clients = Cas::ProjectClient.transaction do
        Cas::ProjectClient.update_all(sync_with_cas: false)
        @client_ids.each do |id|
          client = client_source.find(id)
          project_client = Cas::ProjectClient.
            where(data_source_id: data_source.id, id_in_data_source: id).
            first_or_initialize
          project_client_columns.map do |destination, source|
            project_client[destination] = client.send(source)
          end
          project_client.needs_update = true
          project_client.save!
        end
      end
      if updated_clients.size > 0
        msg = "Updated #{updated_clients.size} ProjectClients in CAS and marked them available"
        @notifier.ping msg if @send_notifications
      end
    end


    def data_source
      @data_source ||= Cas::DataSource.where(name: 'DND Warehouse').first_or_create
    end

    def client_source
      GrdaWarehouse::Hud::Client.cas_active
    end

    def project_client_columns
      {
        first_name: :FirstName,
        last_name: :LastName,
        middle_name: :MiddleName,
        ssn: :SSN,
        ssn_quality_code: :SSNDataQuality,
        date_of_birth: :DOB,
        dob_quality_code: :DOBDataQuality,
        veteran_status: :VeteranStatus,
        homephone: :home_phone,
        cellphone: :cell_phone,
        workphone: :work_phone,
        email: :email,
        substance_abuse_problem: :cas_substance_response,
        primary_race: :cas_primary_race_code,
        gender: :Gender,
        ethnicity: :Ethnicity,
        disabling_condition: :disabling_condition?,
        hivaids_status: :hiv_response?,
        chronic_health_condition: :chronic_response?,
        mental_health_problem: :mental_response?,
        developmental_disability: :developmental_response?,
        physical_disability: :physical_response?,
        # calculated_chronic_homelessness: :chronic?, # using sync_with_cas as a manual proxy
        calculated_chronic_homelessness: :sync_with_cas,
        calculated_first_homeless_night: :date_of_first_service,
        calculated_last_homeless_night: :date_of_last_homeless_service,
        domestic_violence: :domestic_violence?,
        disability_verified_on: :disability_verified_on,
        housing_assistance_network_released_on: :housing_assistance_network_released_on,
        sync_with_cas: :sync_with_cas,
        dmh_eligible: :dmh_eligible,
        va_eligible: :va_eligible,
        hues_eligible: :hues_eligible,
        hiv_positive: :hiv_positive,
        housing_release_status: :housing_release_status,
      }
    end
  end
end