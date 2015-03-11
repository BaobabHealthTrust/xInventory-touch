class UserController < ApplicationController
  before_filter :check_authorized

  def check_authorized
    if action_name == 'new' or action_name == 'index'
       unless admin?
        redirect_to '/'
      end
    end
  end

  def location
    
  end

  def find_location
      site = Site.where(["id = ? OR name = ?", params[:location], params[:location]])
      if ! site.blank?
        session[:site] = site.first.id
        redirect_to '/' and return
      end
      flash[:error] = 'Location was not valid.'
      redirect_to "/location"
  end

  def login
    if request.post?
      user = User.find_by_username params[:user]["username"]
      if user and user.password_matches?(params[:user]["password"])
        session[:user_id] = user.id
        redirect_to "/location" and return
      else
        flash[:error] = 'That username and/or password was not valid.'
      end
    else
      reset_session
    end
  end

  def index
    @users = User.order(:username)
  end

  def logout
    reset_session
    redirect_to '/login'
  end

  def assign_role
    role = UserRoleType.find(params[:role]).name
    UserRole.where("user_id = ?",params[:user_id]).update_all(:role => role)
    render :text => role
  end

  def roles
    @user = User.find(params[:id])
    @roles = UserRoleType.all.collect{|r|[r.name,r.id]}
  end

  def new
    @roles = UserRoleType.order("name").map(&:name)
  end

  def username_availability
    user = User.where("username = ?",params[:search_str])
    render :text => user = user.blank? ? 'available' : 'not available' and return
  end

  def create
    Person.transaction do
      person = Person.new()
      person.first_name = params[:user]['first_name']
      person.last_name = params[:user]['last_name']
      person.save

      user = User.new()
      user.username = params[:user]['username']
      user.password_hash = params[:user]['password']
      user.person_id = person.id
      user.save

      role = UserRole.new()
      role.user_id = user.id
      role.role = params[:user]['role']

      if role.save
        flash[:notice] = 'Successfully created.'
      else
        flash[:error] = 'Something went wrong - did not create.'
      end
    end
    redirect_to "/new_user"
  end

  def edit
    @user = User.find(params[:id])
    @roles = UserRoleType.order("name").map(&:name)
  end

  def update
    Person.transaction do
      person = Person.find(params[:id])
      person.first_name = params[:user]['first_name']
      person.last_name = params[:user]['last_name']
      person.save

      user = person.user
      unless params[:user]['username'].blank?
        user.username = params[:user]['username']
      end

      unless params[:user]['username'].blank?
        user.password_hash = params[:user]['password']
      end
      user.save

      if admin?
        UserRole.where("user_id = ?",user.id).update_all(:role => params[:user]['role'])
      end
      flash[:notice] = 'Successfully created.'
    end
    redirect_to settings_url(:id => 'edit_users')
  end

  def delete
    User.where("id = ?",params[:id]).update_all(:voided => true)
    redirect_to settings_url(:id => 'remove_users')
  end

  def show
    @user = User.find(params[:id])
  end

end
