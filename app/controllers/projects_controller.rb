class ProjectsController < ApplicationController
  before_filter :check_authorized

  def index
    render :layout => 'index'
  end

  def show
    @project = Project.find(params[:id])
    @donor = Donor.find(@project.donor)
  end


  def new
    @donors = ['Select donor', nil]
    Donor.order('name').each do |donor|
      @donors << [donor.name,donor.id]
    end
    @donors = @donors.compact
  end

  def create
    prj = Project.new()                                                         
    prj.name = params[:project]['name']                                         
    prj.donor_id = params[:project]['donor']
    prj.description = params[:project]['description'] unless params[:project]['description'].blank?
    if prj.save                                                               
      flash[:notice] = 'Successfully created.'                                  
    else                                                                        
      flash[:error] = 'Something went wrong - did not create.'                  
    end                                                                         
    redirect_to '/create_new_project'
  end

  def search
    @projects = {}

    (Project.all || []).each do |project|
      @projects[project.id] = {:name => project.name,
        :donor => Donor.find(project.donor).name,
        :date_create => project.created_at,
        :project_id => project.id }
    end
  end

  def edit_project_details 
    @project = Project.find(params[:id])
    if request.post?
      @project.name = params[:project]['name']                                         
      @project.donor = params[:project]['donor']
      @project.description = params[:project]['description'] unless params[:project]['description'].blank?
      @project.save
      redirect_to "/project_details/#{@project.id}"
    end

    @donors = ['Select donor', nil]
    Donor.order('name').each do |donor|
      @donors << [donor.name,donor.id]
    end
    @donors = @donors.compact
  end
  
  def delete
    project = Project.find(params[:id])
    project.voided = true
    project.void_reason = 'Removed by user'
    project.save
    redirect_to '/projects_search'
  end


  private                                                                       
                                                                                
  def check_authorized                                                          
    if action_name == 'new' or action_name == 'create'                          
      unless admin?                                                             
        redirect_to '/projects'                                            
      end                                                                       
    end                                                                         
  end

end
