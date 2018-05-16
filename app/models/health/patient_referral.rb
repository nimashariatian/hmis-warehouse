module Health
  class PatientReferral < HealthBase

    before_validation :update_rejected_from_reason

    # TODO: this needs to be updated with list provided by bhchp 
    # example {rejected_reason_none: 0, rejected_reason_refused_consent: 1}
    # rejected_reason_none: 0 always needs to be there
    # this is the default and means that the patient referral is not rejected
    enum rejected_reason: {rejected_reason_none: 0, rejected_reason_reason_1: 1, rejected_reason_reason_2: 2}

    scope :assigned, -> {where(rejected: false).where.not(agency_id: nil)}
    scope :unassigned, -> {where(rejected: false).where(agency_id: nil)}
    scope :rejected, -> {where(rejected: true)}

    # TODO: What needs to be validated here?
    # TODO: how to validate medicaid id?
    validates_presence_of :first_name, :last_name, :birthdate, :ssn, :medicaid_id
    validates_size_of :ssn, is: 9

    has_many :relationships, class_name: 'Health::AgencyPatientReferral', dependent: :destroy
    belongs_to :assigned_agency, class_name: 'Health::Agency', foreign_key: 'agency_id'

    accepts_nested_attributes_for :relationships

    def update_rejected_from_reason
      if self.rejected_reason_none?
        self.rejected = false
      else
        self.rejected = true
      end
      return true
    end

    def relationship_to(agency)
      relationships.where(agency_id: agency).last
    end

    def assigned?
      agency_id.present?
    end

    def name
      "#{first_name} #{last_name}"
    end

    def age
      if birthdate.present?
        ((Time.now - birthdate.to_time)/1.year.seconds).floor
      else
        'Unknown'
      end
    end

    def self.display_rejected_reason(reason)
      r = reason.split('_')
      r.shift(2)
      result = r.join(' ').capitalize
      if result == 'None'
        'Remove Rejection'
      else
        result
      end
    end

    def display_ssn
      if ssn
        "XXX-XX-#{ssn.chars.last(4).join}"
      else
        'Unknown'
      end
    end

    def display_claimed_by_other(agency)
      cb = display_claimed_by
      other_size = cb.select{|c| c != 'Unclaimed'}.size
      if other_size > 0
        if cb.include?(agency.name)
          other_size = other_size - 1
        end
        if other_size > 0
          agency = 'Agency'.pluralize(other_size)
          "#{other_size} Other #{agency}"
        end
      else
        'Unclaimed'
      end
    end

    def display_claimed_by
      claimed = relationships.claimed
      if claimed.any?
        claimed.map{|r| r.agency.name}
      else
        ['Unclaimed']
      end
    end

    def display_unclaimed_by
      unclaimed = relationships.unclaimed
      unclaimed.map{|r| r.agency.name}
    end

    def self.text_search(text)
      return none unless text.present?
      text.strip!
      pr_t = arel_table
      # Explicitly search for only last, first if there's a comma in the search
      if text.include?(',')
        last, first = text.split(',').map(&:strip)
        where = pr_t[:first_name].lower.matches("#{first.downcase}%")
          .and(pr_t[:last_name].lower.matches("#{last.downcase}%"))
        # Explicity search for "first last"
      elsif text.include?(' ')
        first, last = text.split(' ').map(&:strip)
        where = pr_t[:first_name].lower.matches("#{first.downcase}%")
          .and(pr_t[:last_name].lower.matches("#{last.downcase}%"))
      else
        query = "%#{text.downcase}%"
        
        where = pr_t[:last_name].lower.matches(query).
          or(pr_t[:first_name].lower.matches(query)).
          or(pr_t[:medicaid_id].lower.matches(query))
      end
      where(where)
    end

  end
end