class ProjectsController < ApplicationController
  def show
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
    prj.donor = params[:project]['donor']
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

  def show
    @project = Project.find(params[:id])
  end

end
