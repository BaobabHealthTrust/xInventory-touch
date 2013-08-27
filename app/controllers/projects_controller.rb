class ProjectsController < ApplicationController
  before_filter :check_authorized

  def index
    @page_title = "<h1>projects <small>....</small></h1>"
    render :layout => 'imenu'
  end

  def show
    @project = Project.find(params[:id])
    @donor = @project.donor
    @page_title = "<h1>project <small>details</small></h1>"
    render :layout => 'imenu'
  end

  def found
    @project = Project.where(:name => params[:project])[0]
    redirect_to :action => :show ,:id => @project.id
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
  end

  def find_by_name                                                              
    @projects = Project.where("name LIKE(?)",                                        
      "%#{params[:search_str]}%").group(:name).limit(10).map{|item|[[item.name]]}
    render :text => "<li></li><li>" + @projects.join("</li><li>") + "</li>"       
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
