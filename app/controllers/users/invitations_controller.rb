class Users::InvitationsController < Devise::InvitationsController
  prepend_before_action :require_can_edit_users!, only: [:new, :create]

  # GET /resource/invitation/new
  def new
    @user = User.new
  end

  # POST /resource/invitation
  def create
    if User.with_deleted.find_by_email(invite_params[:email]).present?
      @user = User.with_deleted.find_by_email(invite_params[:email]).restore
    end
    @user = User.invite!(invite_params, current_user)

    if resource.errors.empty?
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      redirect_to admin_users_path
    else
      render :new
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    super
  end

  # PUT /resource/invitation
  def update
    super
  end

  # GET /resource/invitation/remove?invitation_token=abcdef
  def destroy
    super
  end

  protected

  private def invite_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      role_ids: [],
      )
  end

end
