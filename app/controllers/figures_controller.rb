class FiguresController < ApplicationController
  # add controller methods

  get '/figures' do
    @figures = Figure.all
    erb :'/figures/index'
  end

  get '/figures/new' do
    @titles = Title.all
    @landmarks = Landmark.all
    erb :'/figures/new'
  end

  get '/figures/:id/edit' do
    @figure = Figure.find_by_id(params[:id])
    @landmarks = Landmark.all
    @titles = Title.all
    erb :'/figures/edit'
  end

  get '/figures/:id' do
    @figure = Figure.find_by_id(params[:id])
    erb :'/figures/show'
  end

  post '/figures' do
    figure = Figure.create(name: params[:figure][:name])

    unless params[:title][:name].empty?
      title = Title.create(name: params[:title][:name])
      FigureTitle.create(title_id: title.id, figure_id: figure.id)
    end

    if params[:figure][:title_ids]
      params[:figure][:title_ids].each do |id|
        title = Title.find_by_id(id)
        FigureTitle.create(title_id: title.id, figure_id: figure.id)
      end
    end

    if params[:landmark][:name].empty?
      params[:figure][:landmark_ids].each do |id|
        landmark = Landmark.find_by_id(id)
        figure.landmarks << landmark
      end
    end

    unless params[:landmark][:name].empty?
      landmark = Landmark.create(name: params[:landmark][:name],
                                 year_completed: params[:landmark][:year_completed].to_i)
      figure.landmarks << landmark
    end

    redirect "/figures/#{figure.id}"
  end

  patch '/figures/:id' do

    figure = Figure.find_by_id(params[:id])

    figure.update(name: params[:figure][:name]) if figure.name != params[:figure][:name]

    if params[:figure][:title_ids]
      figure.titles.clear
      figure.save
      params[:figure][:title_ids].each do |id|
        figure.titles << Title.find_by_id(id)
      end
    end

    if params[:figure][:landmark_ids]
      figure.landmarks.clear
      figure.save
      params[:figure][:landmark_ids].each do |id|
        figure.landmarks << Landmark.find_by_id(id)
      end
    end

    unless params[:new_landmark][:name].empty?
      figure.landmarks << Landmark.create(name: params[:new_landmark][:name],
                                          year_completed: params[:new_landmark][:year_completed].to_i)
    end

    unless params[:new_title][:name].empty?
      title = Title.create(name:  params[:new_title][:name] )
      FigureTitle.create(title_id: title.id, figure_id: figure.id)
    end

    redirect "/figures/#{figure.id}"
  end
end
