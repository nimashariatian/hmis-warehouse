module CohortColumns
  class CohortDate < Base


    def default_input_type
      :date_picker
    end

    def display_for user
      if display_as_editable?(user, cohort_client)
        content_tag(:div, class: 'input-group date', data: {provide: :datepicker}) do
          content_tag(:div, class: 'form-group') do
            text_field(form_group, column, value: value(cohort_client), size: 10, style: 'width: 8em;', type: :text, class: 'form-control')  
          end +
          content_tag(:span, '', class: 'input-group-addon icon-calendar')
        end
      else
        display_read_only
      end
    end

    def display_read_only
      value(cohort_client)
    end
    
  end
end
