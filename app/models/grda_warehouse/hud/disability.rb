module GrdaWarehouse::Hud
  class Disability < Base
    self.table_name = 'Disabilities'
    self.hud_key = 'DisabilitiesID'
    acts_as_paranoid column: :DateDeleted

    def self.hud_csv_headers(version: nil)
      [
        "DisabilitiesID",
        "ProjectEntryID",
        "PersonalID",
        "InformationDate",
        "DisabilityType",
        "DisabilityResponse",
        "IndefiniteAndImpairs",
        "DocumentationOnFile",
        "ReceivingServices",
        "PATHHowConfirmed",
        "PATHSMIInformation",
        "TCellCountAvailable",
        "TCellCount",
        "TCellSource",
        "ViralLoadAvailable",
        "ViralLoad",
        "ViralLoadSource",
        "DataCollectionStage",
        "DateCreated",
        "DateUpdated",
        "UserID",
        "DateDeleted",
        "ExportID"
      ].freeze
    end

    belongs_to :client, class_name: 'GrdaWarehouse::Hud::Client', foreign_key: ['PersonalID', 'data_source_id'], primary_key: ['PersonalID', 'data_source_id'], inverse_of: :disabilities
    belongs_to :enrollment, **hud_belongs(Enrollment), inverse_of: :disabilities
    belongs_to :export, **hud_belongs(Export), inverse_of: :disabilities
    has_one :destination_client, through: :client

    def self.disability_types
      {
        5 => :physical,
        6 => :developmental,
        7 => :chronic,
        8 => :hiv,
        9 => :mental,
        10 => :substance,
      }
    end

    # This defines ? methods for each disability type, eg: physical? 
    self.disability_types.each do |hud_key, disability_type|
      define_method "#{disability_type}?".to_sym do
        self.DisabilityType == hud_key
      end
    end
    
    # see Disabilities.csv spec version 5
    def response
      if self.DisabilityType == 10
        ::HUD::list('4.10.2', self.DisabilityResponse)
      else
        ::HUD::list('1.8', self.DisabilityResponse)
      end
    end

    def disability_type_text
      ::HUD::disability_type self.DisabilityType
    end
  end
end