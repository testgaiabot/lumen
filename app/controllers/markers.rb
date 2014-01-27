Lumen::App.controllers do
  
  get '/groups/:slug/map' do
    @group = Group.find_by(slug: params[:slug])
    membership_required! 
    if request.xhr?
      partial :'markers/map'
    else    
      erb :'groups/map'  
    end   
  end  
  
  get '/groups/:slug/iframe' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!     
    partial :'markers/iframe', :locals => {
      :points =>
        [
        @group.memberships.map(&:account).map(&:affiliations).flatten.map(&:organisation).uniq,
        @group.markers
      ].sum
    }    
  end   
   
  get '/groups/:slug/map/add' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @marker = @group.markers.build
    erb :'markers/build'
  end
  
  post '/groups/:slug/map/add' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @marker = @group.markers.build(params[:marker])    
    @marker.account = current_account
    if @marker.save  
      flash[:notice] = "<strong>Great!</strong> The marker was created successfully."
      redirect "/groups/#{@group.slug}/map"
    else
      flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the marker from being saved."
      erb :'markers/build'
    end
  end   
  
  get '/groups/:slug/map/:id/edit' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @marker = @group.markers.find(params[:id]) || halt
    erb :'markers/build'
  end
  
  post '/groups/:slug/map/:id/edit' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    @marker = @group.markers.find(params[:id]) || halt
    if @marker.update_attributes(params[:marker])
      flash[:notice] = "<strong>Great!</strong> The marker was updated successfully."
      redirect "/groups/#{@group.slug}/map"
    else
      flash.now[:error] = "<strong>Oops.</strong> Some errors prevented the marker from being saved."
      erb :'markers/build'
    end
  end 
  
  get '/groups/:slug/map/:id/destroy' do
    @group = Group.find_by(slug: params[:slug])
    membership_required!
    (@marker = @group.markers.find(params[:id]) || halt).destroy    
    redirect "/groups/#{@group.slug}/map"
  end 
      
end