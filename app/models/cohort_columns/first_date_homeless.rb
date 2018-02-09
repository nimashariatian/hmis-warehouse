module CohortColumns
  class FirstDateHomeless < Base
    attribute :column, String, lazy: true, default: :first_date_homeless
    attribute :title, String, lazy: true, default: 'First Date Homeless'

    def default_input_type
      :read_only
    end

    def value(cohort_client)
      cohort_client.client.first_date_homeless
    end

  end
end
