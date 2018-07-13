module Window::Health
  class PatientGoalsController < IndividualPatientController

    before_action :set_client
    before_action :set_hpc_patient

    include PjaxModalController
    include WindowClientPathGenerator
    include HealthGoal

    def index
      @goals = @patient.hpc_goals
    end

    def after_path
      polymorphic_path(goals_path_generator)
    end

    def goal_form_path
      if @goal.new_record?
        polymorphic_path(goals_path_generator)
      else
        polymorphic_path(goal_path_generator, id: @goal.id)
      end
    end
    helper_method :goal_form_path

    def new_goal_path
      polymorphic_path([:new] + goal_path_generator)
    end
    helper_method :new_goal_path

    def edit_goal_path(goal)
      polymorphic_path([:edit] + goal_path_generator, id: goal.id)
    end
    helper_method :edit_goal_path

    def delete_goal_path(goal)
      polymorphic_path(goal_path_generator, id: goal.id)
    end
    helper_method :delete_goal_path

  end
end